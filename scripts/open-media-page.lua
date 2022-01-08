function callback(success, result, error)
    if result.status == 0 then
        mp.osd_message("Found matching media", 1)
    else
        mp.osd_message("Unable to find matching media", 3)
    end
end

function launch_media_page()
    mp.osd_message("Finding media page...", 30)
    local script_dir = debug.getinfo(1).source:match("@?(.*/)")
    local table = {}
    table.name = "subprocess"
    table.args = {"python", script_dir.."open-media-page.py", mp.get_property("filename")}
    local cmd = mp.command_native_async(table, callback)
end

-- change key binding as desired 
mp.add_key_binding('ctrl+i', 'launch_media_page', launch_media_page)
