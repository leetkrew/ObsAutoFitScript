obs = obslua

source_name = "iPad Capture"
fit_mode = "fit"  -- default mode

function script_tick(seconds)
    local ok, err = pcall(function()
        local scene_source = obs.obs_frontend_get_current_scene()
        if not scene_source then return end

        local scene = obs.obs_scene_from_source(scene_source)
        if not scene then
            obs.obs_source_release(scene_source)
            return
        end

        local item = obs.obs_scene_find_source(scene, source_name)
        if not item then
            obs.obs_source_release(scene_source)
            return
        end

        local source = obs.obs_sceneitem_get_source(item)
        if not source then
            obs.obs_source_release(scene_source)
            return
        end

        local source_width = obs.obs_source_get_width(source)
        local source_height = obs.obs_source_get_height(source)

        if source_width == 0 or source_height == 0 then
            print("Source dimensions not ready yet.")
            obs.obs_source_release(scene_source)
            return
        end

        local video_info = obs.obs_video_info()
        if not obs.obs_get_video_info(video_info) then
            obs.obs_source_release(scene_source)
            return
        end

        local canvas_width = video_info.base_width
        local canvas_height = video_info.base_height

        -- Determine scale factor
        local scale_x = canvas_width / source_width
        local scale_y = canvas_height / source_height
        local scale

        if fit_mode == "fill" then
            scale = math.max(scale_x, scale_y) -- fill canvas, may crop
        else
            scale = math.min(scale_x, scale_y) -- fit inside canvas
        end

        -- Apply scale
        local transform = obs.obs_sceneitem_get_info(item)
        transform.scale.x = scale
        transform.scale.y = scale
        obs.obs_sceneitem_set_info(item, transform)

        -- Center position
        local pos = obs.vec2()
        pos.x = canvas_width / 2
        pos.y = canvas_height / 2
        obs.obs_sceneitem_set_pos(item, pos)

        obs.obs_source_release(scene_source)
    end)

    if not ok then
        print("AutoFit Error: " .. tostring(err))
    end
end

function script_properties()
    local props = obs.obs_properties_create()

    -- Source dropdown
    local p = obs.obs_properties_add_list(props, "source_name", "Source Name",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources then
        for _, source in ipairs(sources) do
            local name = obs.obs_source_get_name(source)
            obs.obs_property_list_add_string(p, name, name)
        end
        obs.source_list_release(sources)
    end

    -- Fit Mode dropdown
    local mode = obs.obs_properties_add_list(props, "fit_mode", "Fit Mode",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(mode, "Fit (No Crop)", "fit")
    obs.obs_property_list_add_string(mode, "Fill (Crop)", "fill")

    return props
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    fit_mode = obs.obs_data_get_string(settings, "fit_mode")
end

function script_description()
    return [[
Auto-center and scale a source to canvas.

"Fit (No Crop)" - Keeps entire source visible (may have black bars).
"Fill (Crop)" - Fills canvas entirely (may crop edges).
    ]]
end
