/// ap_refresh_overworld_marks()
{
    if (!variable_global_exists("ap_save_loaded") || !global.ap_save_loaded)
        exit;
    if (!variable_global_exists("dm_rando_locations") || is_undefined(dm_rando_locations))
        exit;
    if (!variable_global_exists("ap_checked_ids") || is_undefined(global.ap_checked_ids))
        exit;

    var _count = val(f.dm_rando[?STR_Total+STR_Location+STR_Count]);
    if (is_undefined(_count) || _count <= 0)
        exit;

    // Clear per-OWRC acquired counts, then rebuild
    var _owrc_acquired = ds_map_create();

    var _i, _dk, _owrc, _owrc_, _ap_id, _acq;
    for (_i = 1; _i <= _count; _i++)
    {
        _dk = STR_Location + hex_str(_i);
        _owrc = val(dm_rando_locations[?_dk + STR_OWRC], -1);
        if (_owrc == -1)
        {
            // Location not yet in dm_rando_locations
            var _rm_name = "";
            var _item_id = f.dm_rando[?_dk + STR_Item + STR_ID + STR_Randomized];
            if (!is_undefined(_item_id))
            {
                var _spawn_dk = g.dm_spawn[?_item_id + STR_Spawn + STR_Datakey + STR_Randomized];
                if (is_undefined(_spawn_dk)) _spawn_dk = g.dm_spawn[?_item_id + STR_Spawn + STR_Datakey];
                if (!is_undefined(_spawn_dk))
                    _rm_name = g.dm_spawn[?_spawn_dk + STR_Rm + STR_Name];
            }
            if (is_undefined(_rm_name) || _rm_name == "")
                continue;

            _owrc = g.dm_rm[?_rm_name + STR_OWRC];
            _owrc = val(f.dm_rando[?_rm_name + STR_OWRC], _owrc);
            if (is_undefined(_owrc) || _owrc == -1)
                continue;

            dm_rando_locations[?_dk + STR_OWRC] = _owrc;
        }

        _owrc_ = hex_str(_owrc);
        _ap_id = val(dm_rando_locations[?_dk + "_AP_ID"], 387642575169 + (_i - 1));
        if (variable_global_exists("ap_location_name_to_id")
        && !is_undefined(global.ap_location_name_to_id))
        {
            var _ap_desc = f.dm_rando[?_dk + STR_Description];
            if (!is_undefined(_ap_desc) && _ap_desc != "")
            {
                var _ap_mapped = ds_map_find_value(global.ap_location_name_to_id, _ap_desc);
                if (!is_undefined(_ap_mapped)) _ap_id = real(_ap_mapped);
            }
        }
        dm_rando_locations[?_dk + "_AP_ID"] = _ap_id;
        _acq = sign(ds_list_find_index(global.ap_checked_ids, _ap_id) != -1);
        dm_rando_locations[?_dk + STR_Acquired] = _acq;

        _owrc_acquired[?_owrc_] = val(_owrc_acquired[?_owrc_]) + _acq;

        // Ensure _count1 for this OWRC exists
        if (is_undefined(dm_rando_locations[?_owrc_ + STR_Item + STR_Count]))
            dm_rando_locations[?_owrc_ + STR_Item + STR_Count] = 0;
    }

    // Write back per-OWRC acquired counts
    var _ok = ds_map_find_first(_owrc_acquired);
    while (!is_undefined(_ok))
    {
        dm_rando_locations[?_ok + STR_Acquired + STR_Count] = _owrc_acquired[?_ok];
        _ok = ds_map_find_next(_owrc_acquired, _ok);
    }
    ds_map_destroy(_owrc_acquired);

    show_debug_message("AP: Refreshed overworld marks for " + string(_count) + " locations");
}
