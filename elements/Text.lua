dofile_once("%PATH%oop.lua")
local parsers = dofile_once("%PATH%parsing_functions.lua")
local utils = dofile_once("%PATH%utils.lua")
local DOMElement = dofile_once("%PATH%elements/DOMElement.lua")

-- trim7 from http://lua-users.org/wiki/StringTrim
local function trim(s)
   return s:match("^()%s*$") and '' or s:match("^%s*(.*%S)")
end

local Text = new_class("Text", function(self, xml_element, data_context)
  super(xml_element, data_context)
  local text = trim(xml_element:text())
  self.value = parsers.parse_text(trim(xml_element:text()))
end, DOMElement)

function Text:GetDimensions(gui, data_context)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context:table", 2) end
  local text = inflate(self.value, data_context)
  -- split text into lines
  local lines = utils.split_lines(text)
  local width, height = 0, 0
  for i, line in ipairs(lines) do
    line = trim(line)
    local w, h = GuiGetTextDimensions(gui, line)
    width = math.max(width, w)
    height = height + h
  end
  width = width + self.style.padding_left + self.style.padding_right
  height = height + self.style.padding_top + self.style.padding_bottom
  return width, height
end

function Text:Render(gui, new_id, data_context, layout)
  if not gui then error("Required parameter #1: GuiObject", 2) end
  if not data_context then error("Required parameter #2: data_context", 2) end
  local text = inflate(self.value, data_context)
  local lines = utils.split_lines(text)
  local width, height = self:GetDimensions(gui, data_context)
  local line_height = (height - self.style.padding_top - self.style.padding_bottom) / #lines
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
  for i, line in ipairs(lines) do
    line = trim(line)
    GuiZSetForNextWidget(gui, z)
    if self.style.color then
      local c = self.style.color
      GuiColorSetForNextWidget(gui, c.r, c.g, c.b, math.max(c.a, 0.001))
    end
    GuiText(gui, x + self.style.padding_left, y + self.style.padding_top + (i-1) * line_height, line)
  end

  if self.attr.debug then
    -- Debug rendering
    -- Red = margin
    -- Blue = padding
    -- Green = content
    local function render_debug_rect(x, y, width, height, color)
      if width > 0 and height > 0 then
        GuiZSetForNextWidget(gui, z - 50)
        local r, g, b = unpack(({
          red = { 1, 0, 0 },
          green = { 0, 1, 0 },
          blue = { 0, 0, 1 },
        })[color])
        GuiColorSetForNextWidget(gui, r, g, b, 1)
        GuiImage(gui, 9999, x, y, "data/debug/whitebox.png", 0.5, width / 20, height / 20)
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
