dofile_once("%PATH%oop.lua")
local parser = dofile_once("%PATH%parsing_functions.lua")
local css_props = dofile_once("%PATH%css_props.lua")
local pretty = dofile_once("%PATH%lib/pretty.lua")
local string_buffer = dofile_once("%PATH%string_buffer.lua")

function get_data_from_binding_chain(data_context, binding_target_chain)
  for i, current_target in ipairs(binding_target_chain) do
     -- TODO: With table access, check if it's actually a table
     -- e.g.: one.two.three
     -- when 'one' is a number, trying to access a number value
    data_context = data_context[current_target]
    if data_context == nil then
      error("Bound data variable not found: '" .. tostring(current_target) .."'", 2)
    end
  end
  return data_context
end

-- Get the value from a table like: { type = "value", value = 5 } or { type = "binding", target_chain = ["one"] }
function get_value_from_chain_or_not(data_context, value)
  if value.type == "binding" then
    return get_data_from_binding_chain(data_context, value.target_chain)
  else
    return value.value
  end
end

-- Converts a string like "Hello {{ name }}" into "Hello Peter"
function inflate(tokens, data_context)
  local str = ""
  for i, v in ipairs(tokens) do
    if v.type == "text" then
      str = str .. v.value
    elseif v.type == "binding" then
      local context = data_context
      for i=1, #v.target_chain do
        context = context[v.target_chain[i]]
        if not context then
          error("Unknown identifier: '" .. tostring(v.target_chain[i]) .."'", 2)
        end
      end
      str = str .. tostring(context)
    end
  end
  return str
end

-- Calls the provided function once for each loop iteration, or just once if the element has no loop
-- passing along a data context with loop variables inserted
function loop_call(dom_element, data_context, func, ...)
  if dom_element.loop then
    for i, v in ipairs(data_context[dom_element.loop.binding_target]) do
      local new_context = setmetatable({}, { __index = data_context })
      if dom_element.loop.iter_variable then
        new_context[dom_element.loop.iter_variable] = i
      end
      if dom_element.loop.bind_variable then
        new_context[dom_element.loop.bind_variable] = v
      end
      func(dom_element, new_context, ...)
    end
  else
    func(dom_element, data_context, ...)
  end
end

function concat_table(t)
  local s = ""
  for i, v in ipairs(t) do
    s = s .. ("'%s'"):format(v)
    if next(t, i) then
      s = s .. ", "
    end
  end
  return s
end

ALIGN_ITEMS_HORIZONTAL = {
  LEFT = "left", CENTER = "center", RIGHT = "right"
}
ALIGN_ITEMS_VERTICAL = {
  TOP = "top", CENTER = "center", BOTTOM = "bottom"
}
LAYOUT_DIRECTION = {
  VERTICAL = "vertical", HORIZONTAL = "horizontal"
}

function create_enum_validator(valid_values)
  return function(name, value)
    local is_valid = false
    for i, v in ipairs(valid_values or {}) do
      if v == value then
        is_valid = true
        break
      end
    end
    if not is_valid then
      error(("'%s' must be one of the following: [%s]"):format(name, table.concat(valid_values, ", ")), 6)
    end
  end
end

local DOMElement = new_class("DOMElement", function(self, xml_element, data_context)
  self.name = xml_element.name
  self.class = xml_element.attr.class or ""
  self.data_context = data_context
  local style = {}
  local style_raw = {}
  self.style = setmetatable({
    _set = function(key, value)
      style[key] = value
    end,
    _set_raw = function(key, value)
      style_raw[key] = value
    end,
  }, {
    __index = function(t, key)
      if not css_props[key] then
        error(("Unknown property: '%s'"):format(tostring(key)), 2)
      end
      if style[key] then
        return get_value_from_chain_or_not(data_context, style[key])
      else
        -- Style was not set, check if it's to be inherited
        if css_props[key].inherit then
          return (self.parent and self.parent.style[key]) or css_props[key].default
        else
          -- Get default
          local default = self.default_style[key] or css_props[key].default
          local superclass = self.__superclass
          while default == nil and superclass do
            default = superclass.default_style[key]
            superclass = superclass.__superclass
          end
          return default
        end
      end
    end,
    __newindex = function(t, key, value_string)
      if not css_props[key] then
        error(("Unknown property: '%s'"):format(tostring(key)), 2)
      end
      css_props[key].apply(self.style, value_string)
    end
  })
  local attr = {}
  self.attr = setmetatable({}, {
    __index = function(t, key)
      if not attr[key] then
        return
      end
      return get_value_from_chain_or_not(data_context, attr[key])
    end,
    __newindex = function(t, key, value)
      -- Let us set it once in the constructor but not afterwards
      if not attr[key] then
        attr[key] = value
      else
        error("Please use data binding instead of modifying the attributes directly.", 2)
      end
    end
  })

  self.z = 0
  self.children = {}
  if xml_element.attr.forEach then
    self.loop = parser.parse_loop(string_buffer(xml_element.attr.forEach))
  end
  self:ReadAttribute(xml_element, "debug", false, function(val)
    if val == "true" then
      return true
    elseif val == "false" then
      return false
    end
  end)
  local function read_func(prop, attr)
    local attr = xml_element.attr[attr]
    if attr then
      if attr:match("%(") then
        local func = parse_function_call_expression(attr)
        self[prop] = function()
          return func.execute(data_context, self)
        end
      else
        self[prop] = function()
          local a = {
            type = "binding",
            target_chain = parser.read_binding_target(attr),
          }
          return get_value_from_chain_or_not(data_context, a)
        end
      end
    end
  end
  read_func("render_if", "if")
  read_func("show_if", "show")
end)

DOMElement.default_style = {
  padding_left = 0,
  padding_top = 0,
  padding_right = 0,
  padding_bottom = 0,
  margin_left = 0,
  margin_top = 0,
  margin_right = 0,
  margin_bottom = 0,
}

function DOMElement:QuerySelector(selector_string)
  local selector = parser.parse_style_selector(selector_string)
  local css = dofile_once("%PATH%css.lua")
  local function find_matching_self_or_child(element)
    local s = element
    if css.does_selector_match(s, selector) then
      pretty.table3(selector)
      return s
    else
      for i, child in ipairs(s.children) do
        local matching_element = find_matching_self_or_child(child)
        if matching_element then
          return matching_element
        end
      end
    end
  end
  return find_matching_self_or_child(self)
end

-- Subclasses need to implement GetInnerAndOuterDimensions()
function DOMElement:GetDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local inner_width, inner_height, outer_width, outer_height = self:GetInnerAndOuterDimensions(gui, data_context)
  return outer_width, outer_height
end

function DOMElement:GetRenderOffset(gui, data_context)
  local inner_width, inner_height, outer_width, outer_height = self:GetInnerAndOuterDimensions(gui, data_context)
  -- TODO: Return something like content_width without padding from the child instead of subtracting padding here?
  -- Because it's like adding it first and then subtracting it again?...
  local space_to_move_x = outer_width - (inner_width + self.style.padding_left + self.style.padding_right)
  local space_to_move_y = outer_height - (inner_height + self.style.padding_top + self.style.padding_bottom)
  local x_translate_scale = ({ left=0, center=0.5, right=1 })[self.style.align_self_horizontal]
  local y_translate_scale = ({ top=0, center=0.5, bottom=1 })[self.style.align_self_vertical]
  return x_translate_scale * space_to_move_x, y_translate_scale * space_to_move_y
end

function DOMElement:AddChild(child)
  child.parent = self
  table.insert(self.children, child)
end

function DOMElement:GetZ()
  local parent = self.parent
  local z = 0
  while parent do
    z = z - 100
    parent = parent.parent
  end
  return z
end

function DOMElement:ReadAttribute(xml_element, name, value_default, converter, validator)
  local out
  local value
  local used_default = false
  if xml_element.attr[":" .. name] ~= nil then
    value = self.data_context[xml_element.attr[":" .. name]]
    out = {
      type = "binding",
      target_chain = parser.read_binding_target(xml_element.attr[":" .. name])
    }
  elseif xml_element.attr[name] ~= nil then
    value = xml_element.attr[name]
    if type(converter) == "function" then
      value = converter(value)
    end
    out = {
      type = "value",
      value = value
    }
  else
    used_default = true
    value = value_default
    out = {
      type = "value",
      value = value_default
    }
  end
  if type(validator) == "function" then
    validator(name, value)
  end
  self.attr[name] = out
end

return DOMElement
