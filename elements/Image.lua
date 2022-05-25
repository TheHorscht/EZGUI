dofile_once("%PATH%oop.lua")
dofile_once("%PATH%parsing_functions.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")

local Image = new_class("Image", function(self, xml_element, data_context)
  super(xml_element, data_context)
  self.src = xml_element.attr.src
  self.scaleX = tonumber(xml_element.attr.scaleX) or 1
  self.scaleY = tonumber(xml_element.attr.scaleY) or 1
end, DOMElement)

function Image:GetContentDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  local image_width, image_height = GuiGetImageDimensions(gui, self.src, 1)
  return image_width * self.scaleX, image_height * self.scaleY
end

function Image:Render(gui, new_id, data_context, layout)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context", 2) end
  local x, y = self.style.margin_left, self.style.margin_top
  local offset_x, offset_y = self:GetRenderOffset(gui, data_context)
  local width, height = self:GetDimensions(gui, data_context)
  local border_size = self:GetBorderSize()
  if layout then
    x, y = layout:GetPositionForWidget(gui, data_context, self, width, height)
  end
  local z = self:GetZ()
  self:RenderBorder(gui, new_id, x, y, z, width, height)
  GuiZSetForNextWidget(gui, z)
  if self.style.color then
    local c = self.style.color
    GuiColorSetForNextWidget(gui, c.r, c.g, c.b, math.max(c.a, 0.001))
  end
  GuiImage(gui, new_id(), x + offset_x + self.style.padding_left + border_size, y + offset_y + self.style.padding_top + border_size, self.src, 1, self.scaleX, self.scaleY)
end

return Image
