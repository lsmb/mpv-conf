-- AUTHORS: detuur, zaza42
-- License: MIT
-- link: https://github.com/detuur/mpv-scripts

-- This script minimises and pauses the window when
-- the boss key (default 'b') is pressed.
-- Can be overwriten in input.conf as follows:
-- KEY script-binding boss-key
-- xdotool is required on Xorg(Linux)

local platform = nil --set to 'linux', 'windows' or 'macos' to override automatic assign
if not platform then
  local o = {}
  if mp.get_property_native('options/vo-mmcss-profile', o) ~= o then
    platform = 'windows'
  elseif mp.get_property_native('options/input-app-events', o) ~= o then
    platform = 'macos'
  else
    platform = 'linux'
  end
end

utils = require 'mp.utils'

-- TODO: macOS implementation?
function boss_key()
	mp.set_property_native("pause", true)
	if platform == 'windows' then
	    mp.command([[run cmd /c echo m > \\.\pipe\mpv-boss-key-]]..utils.getpid())
	elseif platform == 'linux' then
            msg.info("Idk it works to this point?")
	    utils.subprocess({ args = {'xdotool', 'getactivewindow', 'windowminimize'} })
	end
end

-- The only way to minimize the window in Windows is through a compiled Win32
-- API call. So we open an async powershell session, define the function call,
-- compile it, and then wait for a signal from this script to execute the call.
-- Signaling is done through named pipes, which to my surprise were present on
-- Windows. Not to my surprise, they didn't work reliably. Writing to the pipe
-- from PS or CMD yields different results, for example. In addition, PS's
-- Events and other async were extremely finnicky. Because of these reasons,
-- and after many, many rewrites, I've arrived at the unorthodox mess that is
-- the code below. It's not pretty, but at l(e)ast it works reliably.

mp.add_key_binding('Ctrl+b', 'boss-key', boss_key)

