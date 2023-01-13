local awful = require('awful')
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
  )
)

return clientKeys
