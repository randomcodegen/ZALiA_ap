// ap_check_location(spawn_datakey, item_id, room_name, x, y)
{
    var _spawn_datakey = argument0;
    if (_spawn_datakey == "" || is_undefined(_spawn_datakey)) exit;

    var _item_id = "";
    if (argument_count > 1) _item_id = argument1;

    var _room_name = "";
    if (argument_count > 2) _room_name = argument2;

    var _x = 0;
    if (argument_count > 3) _x = argument3;

    var _y = 0;
    if (argument_count > 4) _y = argument4;

    if (!global.AP_connected)
    {
        show_debug_message("AP_CHECK: not connected, skipping");
        exit;
    }

    if (!variable_global_exists("AP_location_map"))
    {
        show_debug_message("AP_CHECK: AP_location_map not set (rando not initialized?)");
        exit;
    }

    // 1. Try spawn_datakey
    var _ap_id = global.AP_location_map[?_spawn_datakey];
    var _lookup_used = "spawn";

    // 2. Try coordinate key (e.g. _WestA_29_PRIO00_$F8_$A8)
    if (is_undefined(_ap_id) && _spawn_datakey != "" && _x > 0 && _y > 0)
    {
        var _coord_key = _spawn_datakey + "_" + hex_str(_x) + "_" + hex_str(_y);
        _ap_id = global.AP_location_map[?_coord_key];
        if (!is_undefined(_ap_id))
            _lookup_used = "coord";
        else
            show_debug_message("AP_CHECK: coord key " + _coord_key + " not in map (x=" + string(_x) + " y=" + string(_y) + ")");
    }

    // 3. Try item_id
    if (is_undefined(_ap_id) && _item_id != "" && !is_undefined(_item_id))
    {
        _ap_id = global.AP_location_map[?_item_id];
        if (!is_undefined(_ap_id))
            _lookup_used = "item_id";
    }

    // 4. Last resort: description-based lookup via save
    if (is_undefined(_ap_id) && _item_id != "" && !is_undefined(_item_id)
        && variable_global_exists("ap_location_name_to_id")
        && !is_undefined(global.ap_location_name_to_id))
    {
        var _loc_num = -1;
        if (variable_global_exists("f") && !is_undefined(f) && !is_undefined(f.dm_rando))
            _loc_num = val(f.dm_rando[?_item_id + STR_Location + STR_Num + STR_Randomized], -1);
        if (_loc_num < 0 && variable_global_exists("dm_save_data"))
            _loc_num = val(dm_save_data[?_item_id + STR_Location + STR_Num + STR_Randomized], -1);
        if (_loc_num > 0)
        {
            var _desc_key = STR_Location + hex_str(_loc_num) + STR_Description;
            var _desc2 = "";
            if (variable_global_exists("f") && !is_undefined(f) && !is_undefined(f.dm_rando))
                _desc2 = f.dm_rando[?_desc_key];
            if (is_undefined(_desc2) || _desc2 == "" && variable_global_exists("dm_save_data"))
                _desc2 = dm_save_data[?_desc_key];
            if (!is_undefined(_desc2) && is_string(_desc2) && _desc2 != "")
            {
                var _raw = ds_map_find_value(global.ap_location_name_to_id, _desc2);
                if (!is_undefined(_raw))
                {
                    _ap_id = real(_raw);
                    _lookup_used = "desc";
                    show_debug_message("AP_CHECK_DESC: loc_num=" + string(_loc_num) + " desc='" + _desc2 + "' -> ap_id=" + string(_ap_id));
                }
            }
        }
    }

    show_debug_message("AP_CHECK: spawn=" + string(_spawn_datakey) + " item=" + string(_item_id) + " x=" + string(_x) + " y=" + string(_y) + " used=" + _lookup_used + " -> ap_id=" + string(_ap_id));
    if (is_undefined(_ap_id))
    {
        if (!variable_global_exists("_ap_check_diag_done"))
        {
            global._ap_check_diag_done = true;
            show_debug_message("AP_CHECK DIAG: map size=" + string(ds_map_size(global.AP_location_map)));
            var _dk = ds_map_find_first(global.AP_location_map);
            var _cnt = 0;
            while (!is_undefined(_dk) && _cnt < 10)
            {
                show_debug_message("  map[" + _dk + "] = " + string(global.AP_location_map[?_dk]));
                _dk = ds_map_find_next(global.AP_location_map, _dk);
                _cnt++;
            }
        }
        show_debug_message("AP_CHECK: no entry for spawn=" + string(_spawn_datakey) + " or item=" + string(_item_id));
        exit;
    }

    var _desc = global.AP_location_map[?_spawn_datakey + "_desc"];
    if (_ap_id > 0)
    {
        apclient_location_checks("[" + string(_ap_id) + "]");
        show_debug_message("AP: Checked " + string(_desc) + " (" + string(_ap_id) + ")");
        
        // Track checked locations for re-send on reconnect
        if (!variable_global_exists("ap_checked_ids"))
        {
            global.ap_checked_ids = ds_list_create();
        }
        // Avoid duplicates
        var _dup = false;
        var _k;
        for (_k = 0; _k < ds_list_size(global.ap_checked_ids); _k++)
        {
            if (global.ap_checked_ids[|_k] == _ap_id)
            {
                _dup = true;
                break;
            }
        }
        if (!_dup)
        {
            ds_list_add(global.ap_checked_ids, _ap_id);
        }
    }
}
