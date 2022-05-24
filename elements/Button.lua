dofile_once("data/scripts/lib/utilities.lua")
dofile_once("%PATH%oop.lua")
dofile_once("%PATH%parsing_functions.lua")
local string_buffer = dofile_once("%PATH%string_buffer.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")

local Button = new_class("Button", function(self, xml_element, data_context)
  super(xml_element, data_context)
  self.value = parse_text(xml_element:text())
  self.onClick = parse_function_call_expression(xml_element.attr["@click"])
  self.border_size = 3
end, DOMElement)

Button.default_style = {
  padding_left = 2,
  padding_top = 1,
  padding_right = 2,
  padding_bottom = 1,
  border = true,
}

function Button:GetInnerAndOuterDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local text = inflate(self.value, data_context)
  local inner_width, inner_height = GuiGetTextDimensions(gui, text)
  local border_size = self.style.border and self.border_size or 0
  local outer_width = inner_width + border_size * 2 + self.style.padding_left + self.style.padding_right
  local outer_height = inner_height + border_size * 2 + self.style.padding_top + self.style.padding_bottom
  outer_width = math.max(outer_width, self.style.width or 0)
  outer_height = math.max(outer_height, self.style.height or 0)
  return inner_width, inner_height, outer_width, outer_height
end

function Button:Render(gui, new_id, data_context, layout)
  local text = inflate(self.value, data_context)
  local inner_width, inner_height, outer_width, outer_height = self:GetInnerAndOuterDimensions(gui, data_context)
  local border_size = self.style.border and self.border_size or 0
  local x, y = self.style.margin_left, self.style.margin_top
  if layout then
    x, y = layout:GetPositionForWidget(gui, data_context, self, outer_width, outer_height)
  end
  local z
  if layout then
    z = layout:GetZ()
  else
    z = self:GetZ()
  end
  -- Draw an invisible nine piece which catches mouse clicks, this is to have exact control over the clickable area, which should include padding
  local click_area_width = outer_width - border_size * 2 -- - self.style.padding_left - self.style.padding_right
  local click_area_height = outer_height - border_size * 2 -- - self.style.padding_top - self.style.padding_bottom
  GuiZSetForNextWidget(gui, z - 2)
  GuiImageNinePiece(gui, new_id(), x + border_size, y + border_size, click_area_width, click_area_height, 0.5)
  local clicked, right_clicked, hovered, _x, _y, width, height, draw_x, draw_y, draw_width, draw_height = GuiGetPreviousWidgetInfo(gui)

  -- Draw an invisible image while the button is hovered which prevents mouse clicks from firing wands etc
  if hovered then
    GuiColorSetForNextWidget(gui, 1, 0, 0, 1)
    GuiZSetForNextWidget(gui, z - 3)
    GuiImage(gui, new_id(), x + border_size, y + border_size, "data/debug/whitebox.png", self.attr.debug and 0.5 or 0, click_area_width / 20, click_area_height / 20)
  elseif self.attr.debug then
    GuiColorSetForNextWidget(gui, 0, 1, 0, 1)
    GuiZSetForNextWidget(gui, z - 3)
    GuiImage(gui, new_id(), x + border_size, y + border_size, "data/debug/whitebox.png", 0.5, click_area_width / 20, click_area_height / 20)
  end

  if clicked then
    self.onClick.execute(data_context, self)
  end

  local outer_width = inner_width + border_size * 2 + self.style.padding_left + self.style.padding_right
  local outer_height = inner_height + border_size * 2 + self.style.padding_top + self.style.padding_bottom
  local outer_width2 = math.max(outer_width, self.style.width or 0)
  local outer_height2 = math.max(outer_height, self.style.height or 0)
  local w = outer_width2 - outer_width
  local h = outer_height2 - outer_height
  local space_to_move_x = w
  local space_to_move_y = h
  -- local space_to_move_x = math.max(self.style.width or 0, outer_width) - inner_width
  -- local space_to_move_y = math.max(self.style.height or 0, outer_height) - inner_height
  local x_translate_scale = ({ left=0, center=0.5, right=1 })[self.style.align_self_horizontal]
  local y_translate_scale = ({ top=0, center=0.5, bottom=1 })[self.style.align_self_vertical]
  local offset_x = x_translate_scale * space_to_move_x
  local offset_y = y_translate_scale * space_to_move_y
  if hovered then
    GuiColorSetForNextWidget(gui, 1, 1, 0, 1)
  else
    local c = self.style.color or { r = 1, g = 1, b = 1, a = 1 }
    GuiColorSetForNextWidget(gui, c.r, c.g, c.b, math.max(c.a, 0.001))
  end
  GuiZSetForNextWidget(gui, z - 4)
  GuiText(gui, x + offset_x + border_size + self.style.padding_left, y + offset_y + border_size + self.style.padding_top, text)

  if self.style.border then
    GuiZSetForNextWidget(gui, z - 1)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NoLayouting)
    -- Width and height are based on the inside
    GuiImageNinePiece(gui, new_id(), draw_x + border_size, draw_y + border_size, click_area_width, click_area_height)
  end
end

return Button
