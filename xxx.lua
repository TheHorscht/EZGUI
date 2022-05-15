local d = dofile("EZGUI.lua").init()

local data = {
  counter = 1,
  elements = {
    "Bloo", "Blaa", "Blee",
  },
  align_items_horizontal = "center",
  align_items_vertical = "top",
  direction = "vertical",
  pleft = {
    val = 22
  },
  margin_left = 0,
  margin_top = 0,
  margin_right = 0,
  margin_bottom = 0,
  padding_left = 0,
  padding_top = 0,
  padding_right = 0,
  padding_bottom = 0,
  increase_counter = function(data, element, amount)
    data.counter = data.counter + amount
  end,
  add_element = function(data, element)
    table.insert(data.elements, "New element!")
  end,
  remove_element = function(data, element)
    table.remove(data.elements, #data.elements)
  end,
  move_down = function(data, element, amount)
    element.parent.margin_top = element.parent.margin_top + amount
  end,
  set_align_items_horizontal = function(data, element, alignment)
    data.align_items_horizontal = alignment
  end,
  set_align_items_vertical = function(data, element, alignment)
    data.align_items_vertical = alignment
  end,
  set_direction = function(data, element, direction)
    data.direction = direction
  end,
}

dofile_once("unit_tests.lua")

local parser = dofile_once("parsing_functions.lua")
local pretty = dofile_once("lib/pretty.lua")
local css = dofile_once("css.lua")

local a = d(0, 0, "../../gui.xml", data)
