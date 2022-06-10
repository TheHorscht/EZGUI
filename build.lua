local build_config = dofile("build_config.lua")

if not build_config.mod_id then error("build_config.mod_id is required") end
if not build_config.data_path then error("build_config.data_path is required") end
if not build_config.gui_xml_path then error("build_config.gui_xml_path is required") end
if not build_config.out_file then error("build_config.out_file is required") end

local mod_id = build_config.mod_id
local data_path = build_config.data_path
local gui_xml_path = build_config.gui_xml_path
local out_file = build_config.out_file

-- Remove trailing slash and add it again, so we always end up with a path with a slash at the end
data_path = data_path:gsub("/$", ""):gsub("\\$", "") .. "\\"

local cache = {}
local out = [[
IS_MOD_SETTINGS = true
local __dofile_cache = {}
]]
out = out .. ([[mod_id = "%s"]] .. "\n"):format(mod_id)

local function stitch_file(path)
  local actual_file_path = path:gsub("^data/", data_path)
  local file = assert(io.open(actual_file_path, "rb"))
  local content = file:read("*a")
  content = content:gsub("%%PATH%%", "")
  file:close()
  out = out .. ([[
------ %s ------
__dofile_cache["%s"] = function()
%s
end
]]):format(path, path, content)
end

local files_to_bundle = {
  "utils.lua",
  "string_buffer.lua",
  "parsing_functions.lua",
  "oop.lua",
  "EZGUI.lua",
  "css.lua",
  "css_props.lua",
  "lib/pretty.lua",
  "lib/nxml.lua",
  "elements/Button.lua",
  "elements/Input.lua",
  "elements/DOMElement.lua",
  "elements/Image.lua",
  "elements/Layout.lua",
  "elements/Slider.lua",
  "elements/Checkbox.lua",
  "elements/Text.lua",
  "data/scripts/lib/utilities.lua",
}

for i, path in ipairs(files_to_bundle) do
  stitch_file(path)
end

local nxml = dofile("lib/nxml.lua")
local f = assert(io.open(gui_xml_path, "rb"))
local gui_xml = f:read("*a")
f:close()
local gui_nxml = nxml.parse_many(gui_xml)

function serializeTable(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0
  -- local nl = "\n"
  local nl = ""
  local tmp = string.rep(skipnewlines and "" or " ", depth)
  if type(name) == "number" then
    name = "[" .. name .. "]"
  elseif name and (name:find("^@") or name:find("^:")) then
    name = "['" .. name .. "']"
  end
  if name then tmp = tmp .. name .. " = " end

  if type(val) == "table" then
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
    for k, v in pairs(val) do
      tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
    end
    if val.text then
      local text, pos = val:text()
      if text ~= "" then
        tmp = tmp .. ("text = function() return [[%s]], %d end,\n"):format(text, pos)
      end
    end
    tmp = tmp .. string.rep(skipnewlines and "" or " ", depth) .. "}"
  elseif type(val) == "number" then
    tmp = tmp .. tostring(val)
  elseif type(val) == "string" then
    tmp = tmp .. string.format("%q", val)
  elseif type(val) == "boolean" then
    tmp = tmp .. (val and "true" or "false")
  elseif name == "text" then
    local text, pos = val()
    tmp = tmp .. ("function() return [[%s]], %d end"):format(text, pos)
  else
    tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
  end

  return tmp
end

local utils = dofile("utils.lua")
local mod_settings = {}
local function get_mod_settings_recursive(nxml_element)
  if nxml_element.attr and nxml_element.attr.bind and nxml_element.attr.scope then
    table.insert(mod_settings, { id = nxml_element.attr.bind, scope = nxml_element.attr.scope, default = nxml_element.attr.default })
  end
  for child in nxml_element:each_child() do
    get_mod_settings_recursive(child)
  end
end
get_mod_settings_recursive(gui_nxml[1])

out = out .. "local settings = {\n"
for i, v in ipairs(mod_settings) do
  local default = v.default
  if tonumber(default) then
    default = tonumber(default)
  else
    default = ([["%s"]]):format(default)
  end
  out = out .. ([[  { id = "%s", scope = %s, default = %s },]] .. "\n"):format(v.id, utils.mod_setting_scope_enums[v.scope], default)
end
out = out .. "}"

local serialized_gui_xml = serializeTable(gui_nxml, nil, true)

out = out .. "\nlocal content = {\n  xml = " .. serialized_gui_xml .. ",\n  xml_string = [[" .. gui_xml .. "]]\n}\n"

local f = assert(io.open("settings_template.lua", "rb"))
local settings_template = f:read("*a")
f:close()

local file = assert(io.open(out_file, "wb"))
file:write(out .. [[

function dofile(path)
  if not __dofile_cache[path] then
    error("File not cached: " .. path, 2)
  end
  return __dofile_cache[path]()
end
function dofile_once(path)
  if not __dofile_cache[path] then
    error("File not cached: " .. path, 2)
  end
  return __dofile_cache[path]()
end
]] .. settings_template)

file:close()
