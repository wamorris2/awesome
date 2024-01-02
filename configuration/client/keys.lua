local awful = require('awful')
local cyclefocus = require('cyclefocus')
require('awful.autofocus')
local modkey = require('configuration.keys.mod').modKey
local altkey = require('configuration.keys.mod').altKey

local clientKeys =
  awful.util.table.join(
  awful.key({modkey}, 'f',
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = 'toggle fullscreen', group = 'client'}
  ),
  awful.key({modkey}, 'm',
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    {description = 'toggle maximize', group = 'client'}
  ),
  awful.key({modkey}, 'n', 
    function(c) 
      c.minimized = true 
    end, 
    {description = 'minimize', group = 'client'}
  ),
  awful.key(
    {modkey}, 'q',
    function(c)
      c:kill()
    end,
    {description = 'close', group = 'client'}
  ),
  cyclefocus.key({altkey}, "Tab", {
    -- cycle_filters as a function callback:
    -- cycle_filters = { function (c, source_c) return c.screen == source_c.screen end },

    -- cycle_filters from the default filters:
    cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
    keys = {'Tab', 'ISO_Left_Tab'},  -- default, could be left out
    move_mouse_pointer = false
  })
)

return clientKeys
