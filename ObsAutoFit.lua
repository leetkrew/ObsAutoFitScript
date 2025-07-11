obs = obslua

source_name = "iPad Capture"

function script_tick(seconds)
    local current_scene_source = obs.obs_frontend_get_current_scene()
    if not current_scene_source then return end

    local current_scene = obs.obs_scene_from_source(current_scene_source)
    if not current_scene then
        obs.obs_source_release(current_scene_source)
        return
    end

    local sceneitem = obs.obs_scene_find_source(current_scene, source_name)
    if sceneitem ~= nil then
        local video_info = obs.obs_video_info()
        if obs.obs_get_video_info(video_info) then
            local canvas_width = video_info.base_width
            local canvas_height = video_info.base_height

            obs.obs_sceneitem_set_bounds_type(sceneitem, obs.OBS_BOUNDS_SCALE_INNER)
            obs.obs_sceneitem_set_bounds_alignment(sceneitem, 4)

            local bounds = obs.vec2()
            bounds.x = canvas_width
            bounds.y = canvas_height
            obs.obs_sceneitem_set_bounds(sceneitem, bounds)
        end
    end

    obs.obs_source_release(current_scene_source)
end

-- Make source_name configurable
function script_properties()
    local props = obs.obs_properties_create()
    local p = obs.obs_properties_add_list(props, "source_name", "Source Name",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)

    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local name = obs.obs_source_get_name(source)
            obs.obs_property_list_add_string(p, name, name)
        end
        obs.source_list_release(sources)
    end

    return props
end


function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
end

function script_description()
    return [[
Auto-fits the selected source to the canvas and centers it horizontally.
- Scales to fit without distortion
- Aligns to the top-center
- Useful for iPad or mobile device capture sources
    ]]
end
