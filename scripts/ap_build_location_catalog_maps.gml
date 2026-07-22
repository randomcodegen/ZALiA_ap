/// ap_build_location_catalog_maps()
{
    if (!global.ap_created_manifest_ready) exit;

    if (is_undefined(global.ap_location_name_to_id))
        global.ap_location_name_to_id = ds_map_create();
    else
        ds_map_clear(global.ap_location_name_to_id);
    ds_map_clear(global.ap_id_to_location_name);

    if (is_undefined(global.ap_kakusu_id_by_index))
        global.ap_kakusu_id_by_index = ds_map_create();
    else
        ds_map_clear(global.ap_kakusu_id_by_index);

    // Current protocol supplies the fixed index mapping directly.
    if (variable_global_exists("ap_slot_kakusu_location_ids")
    && !is_undefined(global.ap_slot_kakusu_location_ids)
    && ds_exists(global.ap_slot_kakusu_location_ids, ds_type_map))
    {
        var _slot_kakusu_key = ds_map_find_first(global.ap_slot_kakusu_location_ids);
        while (!is_undefined(_slot_kakusu_key))
        {
            global.ap_kakusu_id_by_index[?string(_slot_kakusu_key)] = real(
                global.ap_slot_kakusu_location_ids[?_slot_kakusu_key]);
            _slot_kakusu_key = ds_map_find_next(global.ap_slot_kakusu_location_ids,
                _slot_kakusu_key);
        }
    }

    var _max_loc_num = 0;
    var _location_id = ds_map_find_first(global.ap_created_location_ids);
    while (!is_undefined(_location_id))
    {
        var _location_num = real(global.ap_created_location_ids[?_location_id]);
        var _location_name = apclient_get_location_name(real(_location_id), "ZALiA");
        if (_location_name != "" && _location_name != "Unknown")
        {
            global.ap_location_name_to_id[?_location_name] = real(_location_id);
            global.ap_id_to_location_name[?real(_location_id)] = _location_name;
        }
        if (_location_num > _max_loc_num) _max_loc_num = _location_num;

        _location_id = ds_map_find_next(global.ap_created_location_ids, _location_id);
    }
    global.ap_max_loc_num = _max_loc_num;
    show_debug_message("AP: built runtime location catalog maps from data package ("
        + string(ds_map_size(global.ap_location_name_to_id)) + " named locations)");
}
