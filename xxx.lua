local d = dofile("EZGUI.lua").init()

local data = {
  counter = 1,
  elements = {
    "Bloo", "Blaa", "Blee",
  },
  position = {},
  align_items_horizontal = "center",
  align_items_vertical = "top",
  align_self_horizontal = "center",
  align_self_vertical = "top",
  direction = "vertical",
  button_margin = 0,
  margin_top = 0,
  margin_right = 0,
  margin_bottom = 0,
  padding_left = 0,
  padding_top = 0,
  padding_right = 0,
  color = { r = 1, g = 1, b = 1, a = 1 },
  padding = 0,
  margin = 0,
  width = 0,
  user = {
    name = "What"
  },
  height = 0,
  ip = "123.123.123.133",
  port = 99,
  padding_bottom = 0,
  condition_true = true,
  condition_false = false,
  set_alignment = function(alignment)
    if ({left=1, hcenter=1, right=1})[alignment] then
      self.align_self_horizontal = ({left="left", hcenter="center", right="right"})[alignment]
    else
      self.align_self_vertical = ({top="top", vcenter="center", bottom="bottom"})[alignment]
    end
  end,
  condition_func = function()
    return math.floor(GameGetFrameNum() / 60) % 2 == 0
  end,
  debug_layout = true,
  debug_text = true,
  debug_button = true,
  set_align_items_horizontal = function(alignment)
    self.align_items_horizontal = alignment
  end,
  set_align_items_vertical = function(alignment)
    self.align_items_vertical = alignment
  end,
  set_direction = function(direction)
    self.direction = direction
  end,
  toggle_debug_layout = function()
    self.debug_layout = not self.debug_layout
  end,
  toggle_debug_text = function(direction)
    self.debug_text = not self.debug_text
  end,
  toggle_debug_button = function()
    self.debug_button = not self.debug_button
  end,
  start_server = function(direction)
    GamePrint("Blob")
  end
}

dofile_once("unit_tests.lua")

local parser = dofile_once("parsing_functions.lua")
local pretty = dofile_once("lib/pretty.lua")
local css = dofile_once("css.lua")

-- local a = d(0, 0, "../../gui2.xml", data)
