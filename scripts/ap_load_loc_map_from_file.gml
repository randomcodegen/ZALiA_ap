/// ap_load_loc_map_from_file()
{
    var _cfg_dir = environment_get_variable("LOCALAPPDATA");
    if (_cfg_dir == "") _cfg_dir = working_directory;
    var _map_path = _cfg_dir + "\ZALiA\zalia_loc_id_map.json";

    if (file_exists(_map_path))
    {
        var _f = file_text_open_read(_map_path);
        var _file_data = file_text_read_string(_f);
        file_text_close(_f);
        var _loc_map = json_decode(_file_data);
        if (_loc_map != -1)
        {
            global.ap_location_name_to_id = _loc_map;
            show_debug_message("AP: location_name_to_id loaded from " + _map_path + " (" + string(ds_map_size(_loc_map)) + " locations)");

            // Build the reverse map (AP location id -> name)
            if (!variable_global_exists("ap_id_to_location_name") || is_undefined(global.ap_id_to_location_name))
                global.ap_id_to_location_name = ds_map_create();
            ds_map_clear(global.ap_id_to_location_name);
            var _base_id = 387642575169;
            var _max_locnum = 0;
            var _nk = ds_map_find_first(_loc_map);
            while (!is_undefined(_nk))
            {
                var _nv = _loc_map[?_nk];
                if (!is_undefined(_nv))
                {
                    global.ap_id_to_location_name[?real(_nv)] = _nk;
                    var _ln = real(_nv) - _base_id + 1;
                    if (_ln > _max_locnum) _max_locnum = _ln;
                }
                _nk = ds_map_find_next(_loc_map, _nk);
            }
            if (_max_locnum > 0) global.ap_max_loc_num = _max_locnum;
            show_debug_message("AP: built id->name reverse map (" + string(ds_map_size(global.ap_id_to_location_name)) + " entries, max loc_num=" + string(global.ap_max_loc_num) + ")");
        }
        else
        {
            show_debug_message("AP: Failed to decode zalia_loc_id_map.json");
        }
    }
    else
    {
        show_debug_message("AP: location_name_to_id file not found at " + _map_path);
    }

    // Individual Kakusu index -> AP location id
    var _kakusu_path = _cfg_dir + "\ZALiA\zalia_kakusu_id_by_index.json";
    if (file_exists(_kakusu_path))
    {
        var _kf = file_text_open_read(_kakusu_path);
        var _kf_data = file_text_read_string(_kf);
        file_text_close(_kf);
        var _k_map = json_decode(_kf_data);
        if (_k_map != -1)
        {
            global.ap_kakusu_id_by_index = _k_map;
            show_debug_message("AP: kakusu index->id map loaded (" + string(ds_map_size(_k_map)) + " entries)");
        }
        else
        {
            show_debug_message("AP: Failed to decode zalia_kakusu_id_by_index.json");
        }
    }
    else
    {
        show_debug_message("AP: kakusu index->id file not found at " + _kakusu_path);
    }
}
