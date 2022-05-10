dofile_once("%PATH%/oop.lua")
local parsers = dofile_once("%PATH%/parsing_functions.lua")
local DOMElement = dofile_once("%PATH%/elements/DOMElement.lua")

local Text = new_class("Text", function(self, xml_element, data_context)
  super(xml_element, data_context)
  self.value = parsers.parse_text(xml_element:text())
end, DOMElement)

function Text:GetDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local text = inflate(self.value, data_context)
  local width, height = GuiGetTextDimensions(gui, text)
  width = width + self.style.padding_left + self.style.padding_right
  height = height + self.style.padding_top + self.style.padding_bottom
  return width, height
end

function Text:Render(gui, new_id, data_context, layout)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context", 2) end
  local text = inflate(self.value, data_context)
  local width, height = self:GetDimensions(gui, data_context)
  local x, y = self.style.margin_left, self.style.margin_top
  if layout then
    x, y = layout:GetPositionForWidget(self, width, height)
  end
  local z
  if layout then
    z = layout:GetZ()
  else
    z = self:GetZ()
  end
  GuiZSetForNextWidget(gui, z)
  GuiText(gui, x + self.style.padding_left, y + self.style.padding_top, text)

  if self.debug then
    -- Debug rendering
    -- Red = margin
    -- Blue = padding
    -- Green = content
    local function render_debug_rect(x, y, width, height, color)
      if width > 0 and height > 0 then
        GuiZSetForNextWidget(gui, z - 50)
        GuiImage(gui, 9999, x, y, "%PATH%/" .. color .. "_half_alpha_10x10.png", 1, width / 10, height / 10)
        -- GuiImage(gui, new_id(), x + 1, y + 1, "mods/XMLGUI/" .. color .. "_half_alpha_10x10.png", 1, (width - 2) / 10, (height - 2) / 10)
      end
    end
    -- Margins
    -- Top
    render_debug_rect(x - self.style.margin_left, y - self.style.margin_top, width + self.style.margin_left + self.style.margin_right, self.style.margin_top, "red")
    -- Left
    render_debug_rect(x - self.style.margin_left, y, self.style.margin_left, height, "red")
    -- Right
    render_debug_rect(x + width, y, self.style.margin_right, height, "red")
    -- Bottom
    render_debug_rect(x - self.style.margin_left, y + height, width + self.style.margin_left + self.style.margin_right, self.style.margin_bottom, "red")

    -- Padding
    -- Top
    render_debug_rect(x, y, width, self.style.padding_top, "blue")
    -- Left
    render_debug_rect(x, y + self.style.padding_top, self.style.padding_left, height - self.style.padding_top - self.style.padding_bottom, "blue")
    -- Right
    render_debug_rect(x + width - self.style.padding_right, y + self.style.padding_top, self.style.padding_right, height - self.style.padding_top - self.style.padding_bottom, "blue")
    -- Bottom
    render_debug_rect(x, y + height - self.style.padding_bottom, width, self.style.padding_bottom, "blue")
  end
end

return Text
