/// ap_build_complete_map()
{
    if (!variable_global_exists("AP_location_map"))
    {
        show_debug_message("AP_FILL: AP_location_map missing, creating");
        global.AP_location_map = ds_map_create();
    }
    if (!variable_global_exists("ap_location_name_to_id") || is_undefined(global.ap_location_name_to_id))
    {
        show_debug_message("AP_FILL: ap_location_name_to_id not available, skipping");
        exit;
    }

    var _count = val(dm_LOCATIONS[?STR_Total + STR_Location + STR_Count]);
    if (is_undefined(_count) || _count <= 0)
    {
        show_debug_message("AP_FILL: no locations found (count=" + string(_count) + ")");
        exit;
    }
    show_debug_message("AP_FILL: checking " + string(_count) + " locations for missing AP map entries");

    var _loc_num, _desc, _SPAWN_DATAKEY, _item_id, _ap_id, _raw;
    var _added = 0;

    for (_loc_num = 1; _loc_num <= _count; _loc_num++)
    {
        _desc = dm_LOCATIONS[?hex_str(_loc_num) + STR_Description];
        if (is_undefined(_desc) || _desc == "")
            continue;

        _SPAWN_DATAKEY = dm_LOCATIONS[?hex_str(_loc_num) + STR_Spawn + STR_Datakey];

        // Spell fallback: spawn datakey is the NPC's
        if (is_undefined(_SPAWN_DATAKEY) || _SPAWN_DATAKEY == "" || _SPAWN_DATAKEY == "undefined")
        {
            _item_id = dm_save_data[?STR_Location + hex_str(_loc_num) + STR_Item + STR_ID + STR_Randomized];
            if (!is_undefined(_item_id) && Rando_is_spell(_item_id))
            {
                _SPAWN_DATAKEY = g.dm_spawn[?STR_Spell+STR_Spawn+STR_Datakey+_item_id];
            }
        }

        // Get AP ID from description
        _ap_id = 0;
        _raw = ds_map_find_value(global.ap_location_name_to_id, _desc);
        if (!is_undefined(_raw))
            _ap_id = real(_raw);
        if (_ap_id == 0)
            _ap_id = 387642575169 + (_loc_num - 1);

        // Add spawn datakey entry
        if (!is_undefined(_SPAWN_DATAKEY) && _SPAWN_DATAKEY != "" && _SPAWN_DATAKEY != "undefined")
        {
            if (is_undefined(global.AP_location_map[?_SPAWN_DATAKEY]))
            {
                global.AP_location_map[?_SPAWN_DATAKEY] = _ap_id;
                global.AP_location_map[?_SPAWN_DATAKEY + "_desc"] = _desc;
                _added++;

                // Also add coord key if coordinates exist
                var _cx = val(g.dm_spawn[?_SPAWN_DATAKEY + "_x"], 0);
                var _cy = val(g.dm_spawn[?_SPAWN_DATAKEY + "_y"], 0);
                if (_cx > 0 && _cy > 0)
                {
                    var _coord_key = _SPAWN_DATAKEY + "_" + hex_str(_cx) + "_" + hex_str(_cy);
                    if (is_undefined(global.AP_location_map[?_coord_key]))
                    {
                        global.AP_location_map[?_coord_key] = _ap_id;
                    }
                }
            }
        }

        // Add item ID entry (if available and missing)
        _item_id = dm_save_data[?STR_Location + hex_str(_loc_num) + STR_Item + STR_ID + STR_Randomized];
        if (!is_undefined(_item_id) && is_string(_item_id) && _item_id != "")
        {
            if (is_undefined(global.AP_location_map[?_item_id]))
            {
                global.AP_location_map[?_item_id] = _ap_id;
                _added++;
            }
        }
    }

    show_debug_message("AP_FILL: added " + string(_added) + " missing entries (total=" + string(ds_map_size(global.AP_location_map)) + ")");
}
