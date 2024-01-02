local naughty = require("naughty")
local menubar = require("menubar")
local awful = require("awful")

terminal = "alacritty"

all_icon_sizes = {
    '128x128',
    '96x96',
    '72x72',
    '64x64',
    '48x48',
    '36x36',
    '32x32',
    '24x24',
    '22x22',
    '16x16'
}
all_icon_types = {
    'apps',
    'actions',
    'devices',
    'places',
    'categories',
    'status',
    'mimetypes'
}
all_icon_paths = { '/usr/share/icons/' }

local function table_to_string(t)
  local s = "{\n"
  for k,v in pairs(t) do
    if type(k) == "table" then
      s = s..table_to_string(k)
    else
      s = s..tostring(k).."\n"
    end
    if type(v) == "table" then
      s = s..table_to_string(v)
    else
      s = s..tostring(v).."\n"
    end
  end
  return s.."}\n"
end

local utils = {}

function utils.debug(msg)
  naughty.notify({
    text=tostring("awedecons:"..msg),
    timeout=30,
  })
end

function file_exists(filename)
  local file = io.open(filename, 'r')
  local result = (file ~= nil)
  if result then
      file:close()
  end
  return result
end

-- from https://github.com/travisjeffery/awesome-wm/blob/master/freedesktop/utils.lua
function lookup_icon(arg)
    -- arg = {icon: Filepath, icon_sizes[Optional]: Table of sizes from all_icon_sizes}
    if arg.icon:sub(1, 1) == '/' and (arg.icon:find('.+%.png') or arg.icon:find('.+%.xpm')) then
        -- icons with absolute path and supported (AFAICT) formats
        return arg.icon
    else
        local icon_path = {}
        local icon_theme_paths = {}
        if icon_theme then
            for i, path in ipairs(all_icon_paths) do
                table.insert(icon_theme_paths, path .. icon_theme .. '/')
            end
            -- TODO also look in parent icon themes, as in freedesktop.org specification
        end
        table.insert(icon_theme_paths, '/usr/share/icons/hicolor/') -- fallback theme cf spec

        local isizes = arg.icon_sizes or table.clone(all_icon_sizes)

        for i, icon_theme_directory in ipairs(icon_theme_paths) do
            for j, size in ipairs(isizes) do
                for k, icon_type in ipairs(all_icon_types) do
                    table.insert(icon_path, icon_theme_directory .. size .. '/' .. icon_type .. '/')
                end
            end
        end
        -- lowest priority fallbacks
        table.insert(icon_path,  '/usr/share/pixmaps/')
        table.insert(icon_path,  '/usr/share/icons/')

        for i, directory in ipairs(icon_path) do
            if (arg.icon:find('.+%.png') or arg.icon:find('.+%.xpm')) and file_exists(directory .. arg.icon) then
                return directory .. arg.icon
            elseif file_exists(directory .. arg.icon .. '.png') then
                return directory .. arg.icon .. '.png'
            elseif file_exists(directory .. arg.icon .. '.xpm') then
                return directory .. arg.icon .. '.xpm'
            end
        end
    end
end


function utils.print_table(t)
  utils.debug(table_to_string(t))
end

function utils.parse_desktop_file(args)
  local flag = false 
  local program = { show = true, file = args.file }
  for line in io.lines(args.file) do
    for key, value in line:gmatch("(%w+)=(.+)") do 
      program[key] = value
    end
  end

  -- Don't show the program if NoDisplay is true
  -- Only show the program if there is not OnlyShowIn attribute
  -- or if it's equal to 'awesome'
  if program.NoDisplay == "true" or program.OnlyShowIn ~= nil and program.OnlyShowIn ~= "awesome" then
      program.show = false
  end

  if program.Icon then
    program.icon = menubar.utils.lookup_icon_uncached(program.Icon)
    if program.icon ~= nil and not file_exists(program.icon) then
      program.icon = nil
    end
  end

  program.name = program.Name or nil

  if program.Exec then
    local cmdline = program.Exec:gsub("%%c", program.name)
    cmdline = cmdline:gsub("%%[fmuFMU]", "")
    cmdline = cmdline:gsub("%%k", program.file)
    if program.icon_path then
      cmdline = cmdline:gsub('%%i', '--icon ' .. program.icon_path)
    else
      cmdline = cmdline:gsub('%%i', '')
    end
    if program.Terminal == "true" then
      cmdline = terminal .. ' -e ' .. cmdline
    end
    program.exec = function() awful.util.spawn(cmdline) end
  end
  utils.print_table(program)

  --[[local program = menubar.utils.parse_desktop_file(args.file)
  program = {
    name=program.Name,
    icon=program.icon_path,
    exec=function() awful.utils.spawn(program.Exec) end
  }]]--
  return program
end

function parse_folder(args)
  local directories = io.popen('find '.. args.dir ..' -maxdepth 1 -type d')
  for dir in directories:lines() do 
  end
  local desktop_files = io.popen('find '.. args.dir ..' -maxdepth 1 -name "*.desktop"')
  for file in desktop_files:lines() do 
    
  end
end

--- Parse all the .desktop files in a directory
-- @param dir; the directory to parse
-- @param icon_sizes; the sizes of the icons to retrieve
-- @return table with all .desktop entries
function utils.parse_desktop_files(args)
  local programs = {}
  local files = io.popen('find '.. args.dir ..' -maxdepth 1 -name "*.desktop"'):lines()
  for file in files do
      args.file = file
      table.insert(programs, utils.parse_desktop_file(args))
  end
  return programs
end


--utils.debug(lookup_icon("folder"))

return utils

