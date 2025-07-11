obs = obslua

source_name = "iPad Capture" -- Adjust if your source name is different

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

            -- Fit and center horizontally
            obs.obs_sceneitem_set_bounds_type(sceneitem, obs.OBS_BOUNDS_SCALE_INNER)

            -- Center horizontally, top vertically
            -- Alignment values:
            -- 0 = top-left, 4 = top-center, 8 = top-right
            obs.obs_sceneitem_set_bounds_alignment(sceneitem, 4)

            local bounds = obs.vec2()
            bounds.x = canvas_width
            bounds.y = canvas_height
            obs.obs_sceneitem_set_bounds(sceneitem, bounds)
        end
    end

    obs.obs_source_release(current_scene_source)
end

function script_description()
    return "Auto-fits the 'iPad Capture' source to the canvas and centers it horizontally.\nUseful for iPad orientation changes."
end


