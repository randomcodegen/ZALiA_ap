/// Kakusu_update_defeated()


if(state==state_EXPLODE 
&& !is_undefined(             dk_spawn) 
&&  is_undefined(f.dm_kakusu[?dk_spawn]) )
{
    f.kakusu_count = val(f.dm_kakusu[?STR_Defeated+STR_Count]) + 1;
    f.dm_kakusu[?STR_Defeated+STR_Count] = f.kakusu_count;
    f.dm_kakusu[?dk_spawn] = 1;

    // AP diagnostic: for any individually-trackable slime
    if (ap_kakusu_index > 0)
    {
        var _dbg_sd  = (variable_global_exists("ap_slot_data")        && !is_undefined(global.ap_slot_data));
        var _dbg_sel = (variable_global_exists("ap_kakusu_selected")  && !is_undefined(global.ap_kakusu_selected)
                     && !is_undefined(ds_map_find_value(global.ap_kakusu_selected, string(ap_kakusu_index))));
        var _dbg_id  = undefined;
        if (variable_global_exists("ap_kakusu_id_by_index") && !is_undefined(global.ap_kakusu_id_by_index))
            _dbg_id = ds_map_find_value(global.ap_kakusu_id_by_index, string(ap_kakusu_index));

        // Dump the full key sets of both maps
        var _sel_keys = "-";
        if (variable_global_exists("ap_kakusu_selected") && !is_undefined(global.ap_kakusu_selected)
        &&  ds_exists(global.ap_kakusu_selected, ds_type_map))
        {
            _sel_keys = "";
            var _sk = ds_map_find_first(global.ap_kakusu_selected);
            while (!is_undefined(_sk)) { _sel_keys += string(_sk) + ","; _sk = ds_map_find_next(global.ap_kakusu_selected, _sk); }
        }
        var _id_keys = "-";
        if (variable_global_exists("ap_kakusu_id_by_index") && !is_undefined(global.ap_kakusu_id_by_index)
        &&  ds_exists(global.ap_kakusu_id_by_index, ds_type_map))
        {
            _id_keys = "";
            var _ik = ds_map_find_first(global.ap_kakusu_id_by_index);
            while (!is_undefined(_ik)) { _id_keys += string(_ik) + ","; _ik = ds_map_find_next(global.ap_kakusu_id_by_index, _ik); }
        }

        show_debug_message("AP_KAKUSU_DEFEAT: index=" + string(ap_kakusu_index)
            + " dk=" + string(dk_spawn)
            + " connected=" + string(global.AP_connected)
            + " slot_data=" + string(_dbg_sd)
            + " selected=" + string(_dbg_sel)
            + " id_by_index=" + string(_dbg_id));
        show_debug_message("AP_KAKUSU_DEFEAT: selected_keys=[" + _sel_keys + "] id_keys=[" + _id_keys + "]");
    }

    // AP: send a check for this specific Kakusu
    if (global.AP_connected && ap_kakusu_index > 0
    && variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
    {
        // This slime is an AP check only if
        var _is_selected = (variable_global_exists("ap_kakusu_selected")
            && !is_undefined(global.ap_kakusu_selected)
            && !is_undefined(ds_map_find_value(global.ap_kakusu_selected, string(ap_kakusu_index))));
        if (_is_selected
        &&  variable_global_exists("ap_kakusu_id_by_index") && !is_undefined(global.ap_kakusu_id_by_index))
        {
            // Resolve this slime's AP check by its fixed
            var _kakusu_ap_id = ds_map_find_value(global.ap_kakusu_id_by_index, string(ap_kakusu_index));
            if (!is_undefined(_kakusu_ap_id))
            {
                // Prefer the descriptive location name (from
                // for the local log/label; fall back to a generic tag if unavailable.
                var _kakusu_loc_name = "Kakusu " + string(ap_kakusu_index);
                if (variable_global_exists("ap_id_to_location_name") && !is_undefined(global.ap_id_to_location_name))
                {
                    var _rev = ds_map_find_value(global.ap_id_to_location_name, real(_kakusu_ap_id));
                    if (!is_undefined(_rev)) _kakusu_loc_name = _rev;
                }
                global.AP_location_map[?dk_spawn] = _kakusu_ap_id;
                global.AP_location_map[?dk_spawn + "_desc"] = _kakusu_loc_name;
                ap_check_location(dk_spawn, undefined, g.rm_name, x, y);
            }
        }
    }

    // 0: opaque body, normal eyes
    // 1: opaque body, cyclops eye
    // 2: translucent body
    var _TYPE  = 2;
        _TYPE -= body_type==1;
        _TYPE -= body_type==1 && eyes_type==1;
    f.dm_kakusu[?hex_str(f.kakusu_count)+STR_Sprite+STR_Type] = _TYPE;
}




