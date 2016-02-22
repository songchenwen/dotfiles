local fullscreen = mp.get_property("fullscreen")
local pause = mp.get_property("pause")

function property_changed(name, value)
    if name == "pause" then
        pause = value
    end
    if name == "fullscreen" then
        fullscreen = value
    end

    local ontop = mp.get_property_native("ontop")
    if (not pause) and fullscreen then
        if not ontop then
            mp.set_property_native("ontop", true)
        end
    else
        if ontop then
            mp.set_property_native("ontop", false)
        end
    end
end

mp.observe_property("pause", "bool", property_changed)
mp.observe_property("fullscreen", "bool", property_changed)

property_changed(nil, nil)
