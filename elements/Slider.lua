dofile_once("%PATH%oop.lua")
local parser = dofile_once("%PATH%parsing_functions.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")

local Slider = new_class("Slider", function(self, xml_element, data_context)
  super(xml_element, data_context)
  self.binding_target = { type = "binding", target_chain = parser.read_binding_target(xml_element.attr.bind) }
  self:ReadAttribute(xml_element, "min", 0)
  self:ReadAttribute(xml_element, "max", 100)
  self:ReadAttribute(xml_element, "default", 0)
  -- self.width = tonumber(xml_element.attr.width) or 100
  self:ReadAttribute(xml_element, "precision", 0, tonumber)
  self.min_width = 30
end, DOMElement)

Slider.default_style = {
  width = 100
}

local function get_slider_and_text_width(self)
  local char_max_width = 6
  local period_width = 2
  local text_width = #tostring(self.attr.max) * char_max_width
  if self.attr.precision > 0 then
    text_width = text_width + period_width + self.attr.precision * char_max_width
  end
  local slider_width = self.style.width
  return math.max(self.min_width, slider_width), text_width
end

function Slider:GetInnerAndOuterDimensions(gui, data_context)
  local slider_width, text_width = get_slider_and_text_width(self)
  local inner_width = slider_width + text_width
  local inner_height = 8
  local outer_width = inner_width + self.style.padding_left + self.style.padding_right
  local outer_height = inner_height + self.style.padding_top + self.style.padding_bottom
  outer_width = math.max(outer_width, self.style.width or 0, self.min_width)
  outer_height = math.max(outer_height, self.style.height or 0)
  return inner_width, inner_height, outer_width, outer_height
end

function Slider:Render(gui, new_id, data_context, layout)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context", 2) end
  local total_width, total_height = self:GetDimensions(gui, data_context)
  local value = get_value_from_chain_or_not(data_context, self.binding_target)
  local x, y = self.style.margin_left, self.style.margin_top
  if layout then
    x, y = layout:GetPositionForWidget(gui, data_context, self, total_width, total_height)
  end
  local z
  if layout then
    z = layout:GetZ()
  else
    z = self:GetZ()
  end
  GuiZSetForNextWidget(gui, z)
  local slider_width, text_width = get_slider_and_text_width(self)
  slider_width = slider_width - 1 -- To get just a tiny bit of extra room on the right side of text
  local old_value = value
  local new_value = GuiSlider(gui, new_id(), x - 2 + self.style.padding_left, y + self.style.padding_top, "", value, self.attr.min, self.attr.max, self.attr.default, 1, " ", slider_width)
  if math.abs(new_value - old_value) > 0.001 then
    -- TODO: Refactor this
    local context = data_context
    for i=1, #self.binding_target.target_chain-1 do
      context = context[self.binding_target.target_chain[i]]
    end
    context[self.binding_target.target_chain[#self.binding_target.target_chain]] = new_value
  end
  GuiZSetForNextWidget(gui, z)
  if self.style.color then
    local c = self.style.color
    GuiColorSetForNextWidget(gui, c.r, c.g, c.b, math.max(c.a, 0.001))
  end
  GuiText(gui, x + slider_width + 3 + self.style.padding_left, y - 1 + self.style.padding_top, ("%." .. self.attr.precision .. "f"):format(value))
end

return Slider
