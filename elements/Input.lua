dofile_once("%PATH%oop.lua")
local parser = dofile_once("%PATH%parsing_functions.lua")
local utils = dofile_once("%PATH%utils.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")

local Input = new_class("Input", function(self, xml_element, data_context)
  super(xml_element, data_context)
  if not xml_element.attr.bind then
    error("'bind' attribute is required on Input field", 4)
  end
  self.binding_target = { type = "binding", target_chain = parser.read_binding_target(xml_element.attr.bind) }
  self.min_width = 30
end, DOMElement)

Input.default_style = {
  width = 100,
}

function Input:GetInnerAndOuterDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local inner_width, inner_height = math.max(self.min_width, self.style.width), 11
  local outer_width = inner_width + self.style.padding_left + self.style.padding_right
  local outer_height = inner_height + self.style.padding_top + self.style.padding_bottom
  outer_width = math.max(outer_width, self.min_width, self.style.width or 0)
  outer_height = math.max(outer_height, self.style.height or 0)
  return inner_width, inner_height, outer_width, outer_height
end

function Input:Render(gui, new_id, data_context, layout)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context", 2) end
  local width, height = self:GetDimensions(gui, data_context)
  local value = get_value_from_chain_or_not(data_context, self.binding_target)
  local x, y = self.style.margin_left, self.style.margin_top
  if layout then
    x, y = layout:GetPositionForWidget(gui, data_context, self, width, height)
  end
  local z
  if layout then
    z = layout:GetZ()
  else
    z = self:GetZ()
  end
  GuiZSetForNextWidget(gui, z)
  local new_text = GuiTextInput(gui, new_id(), x + self.style.padding_left, y + self.style.padding_top, value, width, 50)
  if new_text ~= value then
    -- TODO: Refactor this
    local context = data_context
    for i=1, #self.binding_target.target_chain-1 do
      context = context[self.binding_target.target_chain[i]]
    end
    context[self.binding_target.target_chain[#self.binding_target.target_chain]] = new_text
  end
end

return Input
