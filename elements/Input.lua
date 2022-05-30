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
  self:ReadAttribute(xml_element, "max_length", 30)
  self:ReadAttribute(xml_element, "allowed_characters", "")
end, DOMElement)

Input.default_style = {
  width = 100,
}

function Input:GetContentDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local border_size = self:GetBorderSize() 
  local inner_width, inner_height = math.max(self.min_width, self.style.width - border_size * 2), 11
  return inner_width, inner_height
end

function Input:Render(gui, new_id, x, y, data_context, layout)
  local info = self:PreRender(gui, new_id, x, y, data_context, layout)
  local value = get_value_from_chain_or_not(data_context, self.binding_target)
  GuiZSetForNextWidget(gui, info.z)
  local new_text = GuiTextInput(gui, new_id(), info.x + info.offset_x + info.border_size + self.style.padding_left, info.y + info.offset_y + info.border_size + self.style.padding_top, value, info.width, self.attr.max_length, self.attr.allowed_characters)
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
