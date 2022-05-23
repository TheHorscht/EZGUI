local orig_dofile = dofile
function dofile(filepath)
  -- Replace "mods/EZGUI_example/" with ""
  -- Replace "data/" with "C:\\Users\\Christian\\AppData\\LocalLow\\Nolla_Games_Noita\\data\\"
  return orig_dofile(filepath:gsub("mods/EZGUI_example/", ""):gsub("%%PATH%%", ""):gsub("data/", "C:\\Users\\Christian\\AppData\\LocalLow\\Nolla_Games_Noita\\data\\"))
    -- return orig_dofile(filepath:gsub("mods/EZGUI_example/", ""):gsub("data/", "C:\\Users\\Christian\\AppData\\LocalLow\\Nolla_Games_Noita\\data\\"))
end

dofile_once_cache = {}
function dofile_once(filepath)
  if dofile_once_cache[filepath] then
    return dofile_once_cache[filepath]
  else
    dofile_once_cache[filepath] = dofile(filepath)
    return dofile_once_cache[filepath]
  end
end

_print = print
_print = function() end

local virtual_file_cache = {}

function ModTextFileGetContent(path)
  path = path:gsub("^/", "")
  if not virtual_file_cache[path] then
    local f = assert(io.open(path, "rb+"))
    local content = f:read("*all")
    f:close()
    virtual_file_cache[path] = content
  end
  return virtual_file_cache[path]
end
function ModTextFileSetContent(path, content)
  virtual_file_cache[path] = content
end
function GuiCreate() return {} end
function GuiStartFrame() end
function GuiText(gui, x, y, text)
  _print(([[GuiText("%s") at (%d, %d)]]):format(text, x, y))
end
function GuiButton(gui, id, x, y, text)
  _print(([[GuiButton("%s") at (%d, %d)]]):format(text, x, y))
end
function GuiLayoutBeginVertical() end
function GuiLayoutBeginHorizontal() end
function GuiLayoutEnd() end
function GuiImageNinePiece() end
function GuiZSetForNextWidget() end
function GuiGetTextDimensions(gui, text) return #text * 6, 10 end
function GuiGetImageDimensions(gui, image_path) return 10, 10 end
function GuiLayoutEnd() end
function GuiSlider() return 1 end
function GuiTextInput() return "" end
function GuiBeginScrollContainer() end
function GuiEndScrollContainer() end
function GuiOptionsAddForNextWidget() end
function GuiColorSetForNextWidget() end
-- function GuiGetPreviousWidgetInfo() return false, false, false, 0, 0, width, height, draw_x, draw_y, draw_width, draw_height end
function GuiGetPreviousWidgetInfo() return false, false, false, 0, 0, 0, 30, 0, 0, 0, 30 end
function GuiImage() end
GUI_OPTION = {
  Layout_NoLayouting = 1
}

dofile("xxx.lua")
