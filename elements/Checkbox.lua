dofile_once("%PATH%oop.lua")
local parser = dofile_once("%PATH%parsing_functions.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")
local utils = dofile_once("%PATH%utils.lua")

-- trim7 from http://lua-users.org/wiki/StringTrim
local function trim(s)
  return s:match("^()%s*$") and '' or s:match("^%s*(.*%S)")
end

local Checkbox = new_class("Checkbox", function(self, xml_element, ezgui_object)
  super(xml_element, ezgui_object)
  self.binding_target = { type = "binding", target_chain = parser.read_binding_target(xml_element.attr.bind) }
  if xml_element.attr["@change"] then
    self.onChange = parse_function_call_expression(xml_element.attr["@change"])
  end
  self.value = parser.parse_text(trim(xml_element:text()))
  self:ReadAttribute(xml_element, "default", false)
  -- if binding to setting, set the mod setting to it's default value and set the data variable to the setting/default
  if self.attr.scope then
    utils.setting_set(table.concat(self.binding_target.target_chain, "."), self.attr.default, true)
    local val = utils.setting_get(table.concat(self.binding_target.target_chain, "."), self.attr.default)
    utils.set_data_on_binding_chain(ezgui_object, self.binding_target.target_chain, val)
  end
end, DOMElement)

Checkbox.default_style = {
  -- width = 100
  margin_top = 1,
  margin_bottom = 1,
}

function Checkbox:GetContentDimensions(gui, ezgui_object)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not ezgui_object then error("Required parameter #2: ezgui_object:table", 2) end
  local text = utils.inflate_text(self.value, ezgui_object)
  local w, h = GuiGetTextDimensions(gui, text)
  return 10 + 2 + w, 10
end

function Checkbox:Render(gui, new_id, x, y, ezgui_object, layout)
  local info = self:PreRender(gui, new_id, x, y, ezgui_object, layout)
  local value = utils.get_value_from_chain_or_not(ezgui_object, self.binding_target)
  -- Draw an invisible image while the button is hovered which prevents mouse clicks from firing wands etc
  if self.hovered then
    GuiColorSetForNextWidget(gui, 1, 0, 0, 1)
    GuiZSetForNextWidget(gui, info.z - 3)
    -- (NOITA BUG) Image click/mouse block area is always width * width
    local max = math.max(info.click_area_width, info.click_area_height)
    GuiImage(gui, new_id(), info.x + info.border_size, info.y + info.border_size, "data/debug/whitebox.png", 0, max / 20, max / 20)
  end

  if info.clicked then
    local new_value = not value
    utils.set_data_on_binding_chain(ezgui_object, self.binding_target.target_chain, new_value)
    GuiZSetForNextWidget(gui, info.z)
    if self.onChange then
      self.onChange.execute(ezgui_object, {
        self = ezgui_object.data,
        element = self,
        value = new_value,
      })
    end
    if self.attr.scope then
      utils.setting_set(table.concat(self.binding_target.target_chain, "."), new_value)
    end
  end


  local x = info.x + info.offset_x + self.style.padding_left + info.border_size + 2
  local y = info.y + info.offset_y + self.style.padding_top + info.border_size + 2
  -- Width and height of GuiImageNinePiece are based on the inside, border gets drawn outside of the area (not 100% sure)
  GuiZSetForNextWidget(gui, info.z - 1)
  GuiImageNinePiece(gui, new_id(), x, y, 6, 6)

  -- Hand picked values to draw a checkmark and cross out of rectangles :)
  if value then
    local w, h = 3, 1.5
    GuiZSetForNextWidget(gui, info.z - 2)
    GuiColorSetForNextWidget(gui, 0, 0.8, 0, 1)
    GuiImage(gui, new_id(), x + 1.5, y + 2, "data/debug/whitebox.png", 1, w / 20, (h+0.5) / 20, math.rad(45))
    GuiZSetForNextWidget(gui, info.z - 2)
    GuiColorSetForNextWidget(gui, 0, 0.8, 0, 1)
    GuiImage(gui, new_id(), x + 1.5, y + 4, "data/debug/whitebox.png", 1, (w+1.75) / 20, h / 20, math.rad(-45))
  else
    local w, h = 6.4, 1.5
    GuiZSetForNextWidget(gui, info.z - 2)
    GuiColorSetForNextWidget(gui, 0.8, 0, 0, 1)
    GuiImage(gui, new_id(), x + 1.5, y, "data/debug/whitebox.png", 1, w / 20, (h+0.5) / 20, math.rad(45))
    GuiZSetForNextWidget(gui, info.z - 2)
    GuiColorSetForNextWidget(gui, 0.8, 0, 0, 1)
    GuiImage(gui, new_id(), x + 0.25, y + 4.75, "data/debug/whitebox.png", 1, w / 20, (h+0.25) / 20, math.rad(-45))
  end

  local text = utils.inflate_text(self.value, ezgui_object)
  GuiZSetForNextWidget(gui, info.z - 2)
  if self.hovered then
    GuiColorSetForNextWidget(gui, 1, 1, 0, 1)
  end
  GuiText(gui, x + 10, y - 2, text)
end

return Checkbox
