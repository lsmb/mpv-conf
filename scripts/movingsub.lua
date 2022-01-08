--mpv.conf -> input-ipc-server=/tmp/mpvsocket
--$ echo 'script-message addscrollingsub "hello world"' | socat - /tmp/mpvsocket

local assdraw = require("mp.assdraw")
local utils = require("mp.utils")

local settings = {
  ass_style = "\\1c&HC8C8B4\\fs33\\bord2",
  speed = 0.3
}

local subs = {}

math.randomseed(os.time())

local function addsub(s)
  if s:len() > 100 then 
    print("too long string", s)
    return
  end
  print("adding scrolling sub", s)
  local w, h = mp.get_osd_size()
  if not w or not h then return end
  local sub = {}
  sub['y'] = (h-45)
  sub['x'] = w
  sub['content'] = s:gsub("^&br!", ""):gsub("&br!", "\\N")
  table.insert(subs, sub)
  playsubs:resume()
end

local function render()
  local ass = assdraw.ass_new()
  ass:new_event()
  ass:append("")
  for key, sub in pairs(subs) do
    local x = sub['x']
    local y = sub['y']
    local content = sub['content']

    content = content:gsub("(>.-\\N)", "{\\1c&H35966f&}%1"):gsub("(\\N[^>])", "{\\1c&HC8C8B4}%1")

    ass:new_event()
    ass:append(string.format("{\\pos(%s,%s)%s}", x, y, settings.ass_style))
    ass:append(content)

    sub['x'] = sub['x'] - settings.speed
    if sub['x'] < -2500 then subs[key] = nil end
  end
  local w, h = mp.get_osd_size()
  mp.set_osd_ass(w, h, ass.text)
  if ass.text == "" then
    playsubs:kill()
  end
end
playsubs = mp.add_periodic_timer(0.001, render)
playsubs:kill()

mp.register_script_message("addscrollingsub", addsub)
