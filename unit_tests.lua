-- function ModTextFileGetContent()
--   return [[
--  <Layout width="100" align_items_horizontal="right">
--   <Text margin_right="10">Boo</Text>
--   <Text margin_right="10">Boo</Text>
-- </Layout>
-- <Style>
-- Text.text_class,
-- Button.button_class,
-- .another_class,
-- Layout {
--   padding_top: .9;
-- padding_left: "5";
-- padding_right: 5;
-- padding_bottom: [one.two.three];
-- }

-- Text.text_class,
-- Button.button_class,
-- .another_class,
-- Layout {
--   padding_top: .9;
-- padding_left: "5";
-- padding_right: 5;
-- padding_bottom: [one.two.three];
-- }
-- </Style>
-- ]]
-- end

local lu = dofile_once("lib/luaunit.lua")

local function catch_function_calls(func, ...)
  local function_calls = {}
  setfenv(func, setmetatable({}, {
    __index = function(self, key)
      if type(_G[key]) == "function" then
        return function(...)
          table.insert(function_calls, {
            name = key,
            args = {...}
          })
          return _G[key](...)
        end
      else
        return _G[key]
      end
    end,
    __newindex = _G,
  }))
  local return_values = {func(...)}
  return function_calls, return_values
end

local function expect(actual)
  return {
    to_be = function(expected)
      if type(actual) ~= type(expected) then
        if type(expected) == "string" then
          expected = ([["%s"]]):format(expected)
        end
        error(("Type mismatch: (%s) (%s)"):format(tostring(expected), tostring(actual)), 2)
      end
      if actual ~= expected then
        error(("Expected (%s), got (%s)"):format(expected, tostring(actual)), 2)
      end
    end,
  }
end

local pretty = dofile_once("%PATH%lib/pretty.lua")
local parser = dofile_once("%PATH%parsing_functions.lua")
local parsed_loop = parser.parse_loop("shid in yooo")
expect(parsed_loop.bind_variable).to_be("shid")
expect(parsed_loop.binding_target).to_be("yooo")

local f = parse_function_call_expression("func(1, 'two', three)")
expect(f.type).to_be("function")
expect(f.name).to_be("func")
expect(type(f.execute)).to_be("function")
expect(#f.args).to_be(3)
expect(f.args[1].type).to_be("number")
expect(f.args[1].value).to_be(1)
expect(f.args[2].type).to_be("string")
expect(f.args[2].value).to_be("two")
expect(f.args[3].type).to_be("variable")
expect(f.args[3].value).to_be("three")

-- local f = parser.parse_identifier_group("  s (hello, 2  )")
local f = parse_text("  (hello, 2  ) {{ shid }}")

-- TODO: Make tests for failures, so it throws the correct errors with correct line numbers etc

--[[ 

assert(does_selector_match({ name = "Text", classes = { "one", "two" }}, { class_name = "two", element_name = "Text" }) == true)
assert(does_selector_match({ name = "Text", classes = { "one", "two" }}, { class_name = "two" }) == true)
assert(does_selector_match({ name = "Text", classes = { "one", "two" }}, { element_name = "Text" }) == true)
assert(does_selector_match({ name = "Text", classes = { "one", "two" }}, { element_name = "Button" }) == false)
assert(does_selector_match({ name = "Text", classes = { "one", "two" }}, { class_name = "three" }) == false)
assert(does_selector_match({ name = "Text" }, { class_name = "one" }) == false)
assert(does_selector_match({ name = "Text" }, { class_name = "one", element_name = "Text" }) == false)
assert(does_selector_match({ name = "Text" }, { element_name = "Button" }) == false)

--]]

local parser = dofile_once("%PATH%parsing_functions.lua")
local pretty = dofile_once("%PATH%lib/pretty.lua")
local css = dofile_once("%PATH%css.lua")
local utils = dofile_once("%PATH%utils.lua")
local nxml = dofile_once("%PATH%lib/nxml.lua")
local select = parser.parse_style_selector

local Layout = dofile_once("%PATH%elements/Layout.lua")
local Text = dofile_once("%PATH%elements/Text.lua")

local s = select(" Layout > .cla > Button ")
expect(s.name).to_be("Button")
expect(s.class).to_be(nil)
expect(s.child_of.name).to_be(nil)
expect(s.descendant_of).to_be(nil)
expect(s.child_of.class).to_be("cla")
expect(s.child_of.descendant_of).to_be(nil)
expect(s.child_of.child_of.name).to_be("Layout")
expect(s.child_of.child_of.class).to_be(nil)

local s = select(" Layout .cla Button ")
expect(s.name).to_be("Button")
expect(s.class).to_be(nil)
expect(s.descendant_of.name).to_be(nil)
expect(s.child_of).to_be(nil)
expect(s.descendant_of.class).to_be("cla")
expect(s.descendant_of.child_of).to_be(nil)
expect(s.descendant_of.descendant_of.name).to_be("Layout")
expect(s.descendant_of.descendant_of.class).to_be(nil)

-- returns the innermost child
local function make_element(xml)
  local xml = nxml.parse(xml)
  local innermost_child = xml
  local function convert(el)
    for child in el:each_child() do
      child.parent = el
      innermost_child = child
      convert(child)
    end
    el.class = el.attr.class
    el.children = nil
    el.attr = nil
  end
  convert(xml)
  return innermost_child
end

-- Test our make_element2 function
lu.assertEquals(make_element([[
<HTML class="html_class">
  <DIV class="div_class">
    <P class="p_class" />
  </DIV>
</HTML>]]), {
  class = "p_class",
  parent = {
      class = "div_class",
      parent = {
          class = "html_class",
          name = "HTML",
      },
      name = "DIV",
  },
  name = "P",
})

-- These function tests is the selector matches for the innermost element
expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]),select("  Layout Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]),select("  .class Text  "))).to_be(false)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select(" Layout .class Text  "))).to_be(false)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select(" Layout Button Text  "))).to_be(false)

expect(css.does_selector_match(make_element([[
<Button>
  <Text class="class" />
</Button>
]]), select(" Layout Button Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Button>
    <Text class="class" />
  </Button>
</Layout>
]]), select(" Layout Button Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Button>
    <Text class="class" />
  </Button>
</Layout>
]]), select(" Layout Text Text  "))).to_be(false)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select(" Button Layout Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select("  Layout > Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select("  Layout > Text  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select("  Layout > *  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Text class="class" />
</Layout>
]]), select("  Layout *  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Button>
    <Text class="class" />
  </Button>
</Layout>
]]), select("  Layout *  "))).to_be(true)

expect(css.does_selector_match(make_element([[
<Layout>
  <Button>
    <Text class="class" />
  </Button>
</Layout>
]]), select("  Layout > *  "))).to_be(false)

expect(css.calculate_selector_specificity(select("  Layout "))).to_be(1)
expect(css.calculate_selector_specificity(select("  Layout > Text  "))).to_be(2)
expect(css.calculate_selector_specificity(select("  Layout Text  "))).to_be(2)
expect(css.calculate_selector_specificity(select("  Layout.class Text  "))).to_be(12)
expect(css.calculate_selector_specificity(select("  Layout Text.class  "))).to_be(12)
expect(css.calculate_selector_specificity(select("  Layout.class Text.class  "))).to_be(22)
expect(css.calculate_selector_specificity(select("  Button Layout.class Text.class  "))).to_be(23)
expect(css.calculate_selector_specificity(select("  Button.class Layout.class Text.class  "))).to_be(33)
expect(css.calculate_selector_specificity(select("  Button.class Layout Text.class  "))).to_be(23)
expect(css.calculate_selector_specificity(select("  Button.class .class Text.class  "))).to_be(32)

local string_buffer = dofile_once("%PATH%string_buffer.lua")

local function is_number(str)
  local buffer = string_buffer(str)
  return peek_number(buffer)
end

assert(is_number("1") == true)
assert(is_number("+1") == true)
assert(is_number("122") == true)
assert(is_number("+122") == true)
assert(is_number("0") == true)
assert(is_number("+0") == true)
assert(is_number("a") == false)
assert(is_number("+a") == false)
assert(is_number("+3") == true)
assert(is_number("-3") == true)
assert(is_number("0.10") == true)
assert(is_number("+0.10") == true)
assert(is_number("0054.100") == true)
assert(is_number("+0054.100") == true)
assert(is_number("54.22100") == true)
assert(is_number("+54.22100") == true)
assert(is_number("54.") == true)
assert(is_number("+54.") == true)
assert(is_number(".") == false)
assert(is_number("+.") == false)
assert(is_number(".45434") == true)
assert(is_number("+.45434") == true)
assert(is_number(".-234") == false)
assert(is_number("+.-234") == false)

expect(parser.read_number_literal("1")).to_be(1)
expect(parser.read_number_literal("+1")).to_be(1)
expect(parser.read_number_literal("122")).to_be(122)
expect(parser.read_number_literal("+122")).to_be(122)
expect(parser.read_number_literal("0")).to_be(0)
expect(parser.read_number_literal("+0")).to_be(0)
expect(parser.read_number_literal("+3")).to_be(3)
expect(parser.read_number_literal("-3")).to_be(-3)
expect(parser.read_number_literal("0.10")).to_be(0.1)
expect(parser.read_number_literal("+0.10")).to_be(0.1)
expect(parser.read_number_literal("0054.100")).to_be(54.1)
expect(parser.read_number_literal("+0054.100")).to_be(54.1)
expect(parser.read_number_literal("54.22100")).to_be(54.221)
expect(parser.read_number_literal("+54.22100")).to_be(54.221)
expect(parser.read_number_literal("-54.22100")).to_be(-54.221)
expect(parser.read_number_literal("54.")).to_be(54)
expect(parser.read_number_literal("+54.")).to_be(54)
expect(parser.read_number_literal(".45434")).to_be(0.45434)
expect(parser.read_number_literal("+.45434")).to_be(0.45434)

local tokens = parser.parse_tokens("5 Yooo 5.123 3 -123.2 +.23 -.25 Hello - 10 boop -43.12")
lu.assertEquals(tokens, {
  { type = "number", value = 5, },
  { type = "identifier", value = "Yooo", },
  { type = "number", value = 5.123, },
  { type = "number", value = 3, },
  { type = "number", value = -123.2, },
  { type = "number", value = 0.23, },
  { type = "number", value = -0.25, },
  { type = "identifier", value = "Hello", },
})

local tokens = parser.parse_tokens("dood #FF00FFFF dood")
lu.assertEquals(tokens, {
  { type = "identifier", value = "dood", },
  { type = "color", value = { r = 1, g = 0, b = 1, a = 1 }, },
  { type = "identifier", value = "dood", },
})

local function make_data(data, computed)
  return { data = data, computed = computed or {} }
end

function testStuff()
  lu.assertEquals(parser.read_hex_color("  #FF00FFFF"), { r = 1, g = 0, b = 1, a = 1 })
  lu.assertEquals(parser.read_hex_color("  #FF00FFFF  "), { r = 1, g = 0, b = 1, a = 1 })
  lu.assertEquals(parser.read_hex_color("  #FF00FF"), { r = 1, g = 0, b = 1, a = 1 })
  lu.assertEquals(parser.read_hex_color("  #FF00FF  "), { r = 1, g = 0, b = 1, a = 1 })
end

function testText()
  local Text = dofile_once("%PATH%elements/Text.lua")
  local ezgui_object = {}
  local text = Text(nxml.parse([[
    <Text>Hello</Text>
  ]]), ezgui_object)
   -- 30 wide, 10 high
  -- layout.style.border = true
  text.style.padding = "1"
  local content_width, content_height, outer_width, outer_height = text:GetDimensions({}, ezgui_object)
  lu.assertEquals(text:GetBorderSize(), 0)
  lu.assertEquals(content_width, 30)
  lu.assertEquals(content_height, 10)
  lu.assertEquals(outer_width, 32)
  lu.assertEquals(outer_height, 12)
end

function test_Layout()
  local ezgui_object = {}
  local xml_element = nxml.parse([[
    <Layout><Text>Hello</Text></Layout>
  ]])
  local layout = Layout(xml_element, ezgui_object)
  layout:AddChild(Text(nxml.parse([[
    <Text>Hello</Text>
  ]]), ezgui_object)) -- 30 wide, 10 high
  layout.style.border = true
  layout.style.padding = "5 10"
  local content_width, content_height, outer_width, outer_height = layout:GetDimensions({}, ezgui_object)
  lu.assertEquals(layout:GetBorderSize(), 3)
  lu.assertEquals(content_width, 30)
  lu.assertEquals(content_height, 10)
  lu.assertEquals(outer_width, 56)
  lu.assertEquals(outer_height, 26)
end

function test_observable()
  local data = {
    players = {
      { name = "Hello", ping = 10 },
      { name = "Hello2", ping = 130 },
      { name = "Hello2", ping = 130 },
    },
    boop = 1,
    stoop = { glob = { 5, 6 } }
  }
  local changed = {}
  utils.make_observable(data, nil, nil, function(path)
    table.insert(changed, path)
  end)

  local bla = {}
  for k, v in data.players[2].__pairs do
    bla[k] = v
  end
  lu.assertEquals(bla, { name = "Hello2", ping = 130 })

  local bla = {}
  for k, v in data.stoop.glob.__ipairs do
    bla[k] = v
  end
  lu.assertEquals(bla, { 5, 6 })

  data.players[2].ping = 99
  lu.assertEquals(data.players[2].ping, 99)
  data.players[1].name = "baapy"
  lu.assertEquals(data.players[1].name, "baapy")
  data.boop = { stoopy = 2 }
  lu.assertEquals(data.boop.stoopy, 2)
  data.boop.stoopy = false
  lu.assertEquals(data.boop.stoopy, false)
  data.stoop.glob[2] = 9
  lu.assertEquals(data.players.__count, 3)
  lu.assertEquals(data.players[2].ping, 99)
  lu.assertEquals(data.players[1].name, "baapy")
  lu.assertEquals(data.boop.stoopy, false)
  lu.assertItemsEquals(changed, { "players.2.ping", "players.1.name", "boop", "boop.stoopy", "stoop.glob.2" })
end

function test_get_data_from_binding_chain()
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ one = 1 }), { "one" }), 1)
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ one = { two = 2 } }), { "one", "two" }), 2)
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ one = { two = { three = 3 } } }), { "one", "two", "three" }), 3)
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ 1 }), { 1 }), 1)
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ { 2 } }), { 1, 1 }), 2)
  lu.assertEquals(utils.get_data_from_binding_chain(make_data({ one = { 1 } }), { "one", 1 }), 1)
end

function test_get_data_from_binding_chain_computed()
  local ezgui_object = {
    data = {},
    computed = {
      one = function() return 1 end
    }
  }
  lu.assertEquals(utils.get_data_from_binding_chain(ezgui_object, { "one" }), 1)
end

function test_loop_call()
  local ezgui_object = {
    data = {
      elements = {
        { boop = 5 },
        { boop = 8 },
      },
      d = { "a", "b", "c" }
    },
    computed = {
      d = function() return { "A", "B", "C" } end
    }
  }
  utils.make_observable(ezgui_object)

  local text = Text(nxml.parse([[<Text forEach="element in elements">{{ element.boop }}</Text>]]), ezgui_object)
  local call_count = 0
  local values = {}
  utils.loop_call(text, ezgui_object, function(text, ezgui_object)
    call_count = call_count + 1
    table.insert(values, utils.get_value_from_ezgui_object(ezgui_object, { "element", "boop" }))
    table.insert(values, utils.get_value_from_ezgui_object(ezgui_object, { "d" })[ezgui_object.data.i])
  end)
  lu.assertEquals(call_count, 2)
  lu.assertEquals(values, { 5, "A", 8, "B" })
end

function test_data_retrieval()
  local ezgui_object = {
    data = {
      element = {
        boop = "yes"
      }
    },
    computed = {},
  }
  local text = Text(nxml.parse([[<Text>Hello {{ element.boop }} boopy</Text>]]), ezgui_object)
  local function_calls, return_values = catch_function_calls(text.Render, text, {}, function() return 1 end, 0, 0, ezgui_object)
  lu.assertTableContains(function_calls, {
    name = "GuiText",
    args = {{}, 0, 0, "Hello yes boopy"}
  })
end

function test_set_data_on_binding_chain()
  local ezgui_object = {
    data = {
      one = 0
    }
  }
  utils.set_data_on_binding_chain(ezgui_object, { "one" }, 1)
  lu.assertEquals(ezgui_object.data.one, 1)

  ezgui_object.data.one = { two = 0 }
  utils.set_data_on_binding_chain(ezgui_object, { "one", "two" }, 2)
  lu.assertEquals(ezgui_object.data.one.two, 2)
  
  ezgui_object.data.one = { two = { three = 3 } }
  utils.set_data_on_binding_chain(ezgui_object, { "one", "two", "three" }, 3)
  lu.assertEquals(ezgui_object.data.one.two.three, 3)

  ezgui_object.data = { 1 }
  utils.set_data_on_binding_chain(ezgui_object, { 1 }, 3)
  lu.assertEquals(ezgui_object.data[1], 3)

  ezgui_object.data = { { 2 } }
  utils.set_data_on_binding_chain(ezgui_object, { 1, 1 }, 2)
  lu.assertEquals(ezgui_object.data[1][1], 2)

  ezgui_object.data = { one = { 1 } }
  utils.set_data_on_binding_chain(ezgui_object, { "one", 1 }, 1)
  lu.assertEquals(ezgui_object.data.one[1], 1)
end

function test_inflate_text()
  local i = utils.inflate_text
  local p = parser.parse_text
  local d = make_data
  lu.assertEquals(i(p("He :)"), d({})), "He :)")
  -- With data
  lu.assertEquals(i(p("He {{ name }} wh"), d({ name = "Peter"})), "He Peter wh")
  lu.assertEquals(i(p("He {{ one.two.three }} bo"), d({ one = { two = { three = 3 }}})), "He 3 bo")
  lu.assertEquals(i(p("He {{ 1 }} sho"), d({ "bo" })), "He bo sho")
  lu.assertEquals(i(p("He {{ 1.1 }} glo"), d({ { "bo" } })), "He bo glo")
  lu.assertEquals(i(p("He {{ 1.meow.1 }} mo"), d({ { meow = { "bo" } } })), "He bo mo")
  -- With computed
  lu.assertEquals(i(p("He {{ bo }} mo"), d({}, { bo = function() return "bl" end })), "He bl mo")
end

function test_get_value_from_ezgui_object()
  local ezgui_object = {
    data = {
      aaa = "aaa",
      bbb = "bbb",
      ccc = {
        ddd = "ddd"
      },
      fff = { "ggg" },
    },
    computed = {
      bbb = function() return "bbb_computed" end,
      eee = function() return "eee" end,
    }
  }
  lu.assertEquals(utils.get_value_from_ezgui_object(ezgui_object, "aaa"), "aaa")
  lu.assertEquals(utils.get_value_from_ezgui_object(ezgui_object, "bbb"), "bbb_computed")
  lu.assertEquals(utils.get_value_from_ezgui_object(ezgui_object, { "ccc", "ddd" }), "ddd")
  lu.assertEquals(utils.get_value_from_ezgui_object(ezgui_object, { "fff", 1 }), "ggg")
  lu.assertEquals(utils.get_value_from_ezgui_object(ezgui_object, "eee"), "eee")
  lu.assertErrorMsgEquals("Data variable not found: 'hhh'", utils.get_value_from_ezgui_object, ezgui_object, "hhh")
  lu.assertErrorMsgEquals("Data variable not found: 'aaa.bbb'", utils.get_value_from_ezgui_object, ezgui_object, { "aaa", "bbb" })
end

teststring = nil -- This is a variable in data/scripts/lib/utilities.lua we need to clear so luaunit doesn't pick it up as a test
lu.LuaUnit.run()
-- lu.LuaUnit.run("-p", "test_stuff")
