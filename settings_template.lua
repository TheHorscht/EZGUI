local utils = dofile_once("utils.lua")
local render_gui = dofile_once("EZGUI.lua").init()
local ezgui_object = {
  data = {
    toggle_value = false,
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
    margin_left = 0,
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
    height = 30,
    ip = "123.123.123.133",
    port = 99,
    padding_bottom = 0,
    condition_true = true,
    condition_false = false,
    debug_layout = true,
    debug_text = true,
    debug_button = true,
    img = "data/debug/circle_56.png",
    y = 200,
    rows = {
      "one", "two", "three"
    },
    player = {
      { name = "Hello2", ping = 130 }
    },
    players = {
      { name = "Hello2", ping = 130 },
      { name = "Hello2", ping = 130 },
    },
    boop = "hello",
  },
  methods = {
    condition_func = function()
      return math.floor(GameGetFrameNum() / 60) % 2 == 0
    end,
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
      print("Togglign debug layout")
      self.debug_layout = not self.debug_layout
    end,
    toggle_debug_text = function(direction)
      self.debug_text = not self.debug_text
    end,
    start_server = function(direction)
      GamePrint("Blob")
    end,
    set_name = function()
      math.randomseed(GameGetFrameNum())
      self.player[1].name = "boopy" .. Random(1, 10)
    end,
    print = function()
      print(value)
    end,
    set_alignment = function(alignment)
      ({
        topleft = function()
          self.align_self_vertical = "top"
          self.align_self_horizontal = "left"
        end,
        top = function()
          self.align_self_vertical = "top"
          self.align_self_horizontal = "center"
        end,
        topright = function()
          self.align_self_vertical = "top"
          self.align_self_horizontal = "right"
        end,
        left = function()
          self.align_self_vertical = "center"
          self.align_self_horizontal = "left"
        end,
        center = function()
          self.align_self_vertical = "center"
          self.align_self_horizontal = "center"
        end,
        right = function()
          self.align_self_vertical = "center"
          self.align_self_horizontal = "right"
        end,
        bottomleft = function()
          self.align_self_vertical = "bottom"
          self.align_self_horizontal = "left"
        end,
        bottom = function()
          self.align_self_vertical = "bottom"
          self.align_self_horizontal = "center"
        end,
        bottomright = function()
          self.align_self_vertical = "bottom"
          self.align_self_horizontal = "right"
        end,
      })[alignment]()
    end,
    changeImage = function()
      if self.img == "data/debug/circle_16.png" then
        self.img = "data/debug/circle_56.png"
      else
        self.img = "data/debug/circle_16.png"
      end
    end,
    value_changed = function()
      print("New value is: " .. tostring(value))
    end
  },
  computed = {
    show_this = function()
      return math.floor(GameGetFrameNum() / 60) % 2 == 1
    end
  },
  watch = {
    ["player.1.name"] = function(value)
      print(self.player[1].name, tostring(value))
    end
  },
}

function ModSettingsGuiCount()
  return 1
end

function ModSettingsUpdate(init_scope)
  for i, setting in ipairs(settings) do
    if setting.scope >= init_scope then
      local value = ModSettingGetNextValue(utils.get_setting_id(setting.id))
      ModSettingSet(utils.get_setting_id(setting.id), value)
    end
  end
end

function ModSettingsGui( gui, in_main_menu )
  GuiText(gui, 0, 0, "")
  local clicked, right_clicked, hovered, x, y, width, height, draw_x, draw_y, draw_width, draw_height = GuiGetPreviousWidgetInfo(gui)
  GuiOptionsAdd(gui, GUI_OPTION.Layout_NoLayouting)
  local width, height = render_gui(draw_x, draw_y, content, ezgui_object, gui)
  GuiOptionsRemove(gui, GUI_OPTION.Layout_NoLayouting)
  GuiText(gui, 0, height, "")
end
