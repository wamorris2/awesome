local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")

local gio = require("lgi").Gio

local xresources = require("beautiful").xresources
local dpi = xresources and xresources.apply_dpi or function() end

local utils = require("awedecons.utils")

local num_screens = 2
local screen_wiboxes = {}
for index=1,num_screens do
  table.insert(screen_wiboxes, {
    wbox=nil,
    decons={}
  })
end

-- Debug variables
local awedecons 
awedecons = {
  -- icon_size; determines the size of the icons and the text
  -- must be a number and a valid icon size up to 256
  -- if this value is nil, it will be deferred to the value of icon_size for each screen
  -- if that value is nil too, it default to 64
  icon_size=nil
  
}

awedecons.screen_filter = {
  {
    show_icons=true,
    icon_size="small",
    num_rows=nil,
    num_cols=nil
  },
  {
    show_icons=true,
    icon_size="medium",
    num_rows=nil,
    num_cols=nil
  }
}

awedecons.icon_sizes = {
  small={
    image_size=64,
    font_size="sans 8"
  },
  medium={
    image_size=96,
    font_size="sans 12"
  },
  large={
    image_size=128,
    font_size="sans 16"
  }
}


--type Result = { 
  --kind: string, -- "Ok" or "Err"
  --value: unknown -- something or nil
--}
--


function get_desktop_folder()
  local folder = os.getenv("HOME").."/Desktop/"
  local ok, err, code = os.rename(folder, folder)
  if not ok then
    return nil
  end
  return folder
end

function scan_desktop_dir()
  local desktop_dir = get_desktop_folder()
  return utils.parse_desktop_files({dir=desktop_dir})
end

---Add an entry to the desktop
-- @param icon;   filepath of the image to use
-- @param name;   name to put under the icon
-- @param click;   command to run on click
-- @param row;    row in the grid layout to add to
-- @param col;    column in the grid layout to add to
function add_icon(args)
  local decon_layout = wibox.layout.fixed.vertical()
  local dlm = wibox.container.margin(decon_layout, dpi(5))
  dlm:buttons(
    gears.table.join(
      awful.button({}, 1, nil, args.exec),
      awful.button({}, 2, nil, args.exec)
    )
  )

  local icon = gears.surface.load(args.icon)
  local icon_size = 64
  local cairo = require("lgi").cairo
  local scaled = cairo.ImageSurface(cairo.Format.ARGB32, icon_size, icon_size)
  local cr = cairo.Context(scaled)
  cr:scale(icon_size / icon:get_height(), icon_size / icon:get_width())
  cr:set_source_surface(icon,0,0)
  cr:paint()
  icon = scaled
  local iconbox = wibox.widget{
    resize = false,
    image = icon,
    forced_height = icon_size,
    forced_width = icon_size,
    widget = wibox.widget.imagebox
  }
  --iconbox:set_resize(false)
  --iconbox:set_image(icon)
  decon_layout:add(iconbox)

  local text = wibox.widget{
    text = args.name,
    align = "center",
    valign = "center",
    font = "sans 12",
    wrap = "word",
    --ellipsize = "end",
    forced_width = icon_size,
    widget = wibox.widget.textbox
  }
  --text:set_markup(decon_table["name"])
  --text.valign = "center"
  --text:set_font("sans 12")
  --text:set_wrap("word_char")
  --text:set_ellipsize("end")
  local text_margin = wibox.container.margin(text)
  text_margin:set_margins(dpi(2))
  decon_layout:add(text_margin)
  dlm = wibox.container.margin(clickable_container(dlm))
  dlm:set_margins(dpi(5))

  return dlm
end

function setup(s)
  if not awedecons.screen_filter[s.index].show_icons then return nil end
  local icon_size = awedecons.icon_size or awedecons.screen_filter[s.index].icon_size or 64
  screen_wiboxes[s.index].decons = awful.util.table.clone(decons)
  local w= wibox({ontop=false, screen=s, bg="#00000000", visible=true})
  w:geometry(s.workarea)
  w.y = 32
  w.height = w.height - 32
  local layout = wibox.layout.grid()
  for _, v in pairs(screen_wiboxes[s.index].decons) do
    layout:add(add_icon(v))
  end
  w:set_widget(layout)
  screen_wiboxes[s.index].wbox = w
end

decons = scan_desktop_dir()


awful.screen.connect_for_each_screen(setup)
-- Core Logic:
-- Search Desktop folder and collect any .desktop files
-- parse the desktop files and get the Name, Icon, and Executible from them
-- make a wibox out of those files and 
