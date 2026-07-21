/// ap_slot_connected(slot_data)
{
    show_debug_message("AP: Slot connected: " + string(argument0));
    global.AP_connected = true;
    global.ap_boss_item_backfill_done = false;
    global.ap_ever_connected = true;
    ap_apply_slot_data(argument0);

    // Load srv's confirmed checked locations.
    if (!variable_global_exists("ap_checked_ids"))
        global.ap_checked_ids = ds_list_create();
    else
        ds_list_clear(global.ap_checked_ids);

    // apclient_get_checked_locations() returns a GML struct string
    var _server_checked = apclient_get_checked_locations();
    var _chk_key = "global.ap_checked_locations[";
    var _chk_klen = string_length(_chk_key);
    var _chk_raw = _server_checked;
    var _chk_added = 0;
    // Safety cap against malformed input.
    var _chk_cap = 256;
    if (variable_global_exists("ap_location_name_to_id") && !is_undefined(global.ap_location_name_to_id)
        && global.ap_location_name_to_id != -1)
        _chk_cap = ds_map_size(global.ap_location_name_to_id) + 16;
    if (_chk_cap < 200) _chk_cap = 200;
    repeat(_chk_cap)
    {
        var _chk_p = string_pos(_chk_key, _chk_raw);
        if (_chk_p == 0) break;
        _chk_raw = string_delete(_chk_raw, 1, _chk_p + _chk_klen - 1);
        // _chk_raw starts at the index digit(s)
        var _chk_eq = string_pos("]=", _chk_raw);
        if (_chk_eq == 0) break;
        // Remove index digits + "]="
        _chk_raw = string_delete(_chk_raw, 1, _chk_eq + 1);
        // _chk_raw now starts at the value
        var _chk_semi = string_pos(";", _chk_raw);
        if (_chk_semi == 0) break;
        var _chk_val = real(string_copy(_chk_raw, 1, _chk_semi - 1));
        _chk_raw = string_delete(_chk_raw, 1, _chk_semi);
        if (_chk_val > 0 && ds_list_find_index(global.ap_checked_ids, _chk_val) == -1)
        {
            ds_list_add(global.ap_checked_ids, _chk_val);
            _chk_added++;
        }
    }
    show_debug_message("AP: Loaded " + string(ds_list_size(global.ap_checked_ids)) + " checked locations (" + string(_chk_added) + " new from server)");

    // Refresh overworld checkmark data with srv-accurate
    ap_refresh_overworld_marks();

    // Scout all ZALiA locations to cache
    ds_map_clear(global.ap_scouted_flags);
    ds_map_clear(global.ap_scouted_players);
    ds_map_clear(global.ap_scouted_item_ids);
    ds_map_clear(global.ap_scouted_sprites);
    ds_map_clear(global.ap_scouted_item_types);
    // Scout every real location for this slot.
    var _scout_ids = "[";
    var _loc_count = 0;

    // A modern slot supplies the exact created-location set. Scout precisely
    // that set; older slots retain the name-map/Kakusu compatibility path.
    var _manifest_scout = false;
    if (variable_global_exists("ap_created_manifest_ready")
    &&  global.ap_created_manifest_ready
    &&  ds_map_size(global.ap_created_location_ids) > 0)
    {
        var _created_id = ds_map_find_first(global.ap_created_location_ids);
        while (!is_undefined(_created_id))
        {
            if (_loc_count > 0) _scout_ids += ",";
            _scout_ids += string(_created_id);
            _loc_count++;
            _created_id = ds_map_find_next(global.ap_created_location_ids, _created_id);
        }
        _manifest_scout = true;
    }

    // Build the set of unselected-Kakusu ids for legacy slots.
    var _kak_exclude = ds_map_create();
    if (variable_global_exists("ap_kakusu_id_by_index") && !is_undefined(global.ap_kakusu_id_by_index)
        && ds_exists(global.ap_kakusu_id_by_index, ds_type_map)
        && variable_global_exists("ap_kakusu_selected") && !is_undefined(global.ap_kakusu_selected)
        && ds_exists(global.ap_kakusu_selected, ds_type_map))
    {
        var _ik = ds_map_find_first(global.ap_kakusu_id_by_index);
        while (!is_undefined(_ik))
        {
            if (is_undefined(ds_map_find_value(global.ap_kakusu_selected, string(_ik))))
            {
                var _kid = global.ap_kakusu_id_by_index[?_ik];
                if (!is_undefined(_kid)) ds_map_add(_kak_exclude, real(_kid), 1);
            }
            _ik = ds_map_find_next(global.ap_kakusu_id_by_index, _ik);
        }
    }

    // Boss-item locations (names ending ": Boss Item")
    var _boss_on = 1;
    if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data)
        && ds_exists(global.ap_slot_data, ds_type_map))
    {
        var _boss_val = ds_map_find_value(global.ap_slot_data, "boss_item_locations");
        if (!is_undefined(_boss_val)) _boss_on = real(_boss_val);
    }
    var _bi_suffix = ": Boss Item";
    var _bi_len = string_length(_bi_suffix);
    var _scout_seen = ds_map_create();

    if (!_manifest_scout
        && variable_global_exists("ap_location_name_to_id") && !is_undefined(global.ap_location_name_to_id)
        && global.ap_location_name_to_id != -1 && ds_map_size(global.ap_location_name_to_id) > 0)
    {
        var _mk = ds_map_find_first(global.ap_location_name_to_id);
        while (!is_undefined(_mk))
        {
            var _mid = global.ap_location_name_to_id[?_mk];
            if (!is_undefined(_mid))
            {
                var _skip = (!is_undefined(ds_map_find_value(_kak_exclude, real(_mid))));
                if (!_skip && _boss_on == 0 && string_length(_mk) >= _bi_len
                    && string_copy(_mk, string_length(_mk) - _bi_len + 1, _bi_len) == _bi_suffix)
                    _skip = true;
                if (!_skip)
                {
                    if (_loc_count > 0) _scout_ids += ",";
                    _scout_ids += string(_mid);
                    _scout_seen[?real(_mid)] = 1;
                    _loc_count++;
                }
            }
            _mk = ds_map_find_next(global.ap_location_name_to_id, _mk);
        }
    }

    // Selected individual Kakusu are AP-only locations
    if (!_manifest_scout && _loc_count > 0
    &&  variable_global_exists("ap_kakusu_selected")
    && !is_undefined(global.ap_kakusu_selected)
    &&  variable_global_exists("ap_kakusu_id_by_index")
    && !is_undefined(global.ap_kakusu_id_by_index))
    {
        var _sk_sel = ds_map_find_first(global.ap_kakusu_selected);
        while (!is_undefined(_sk_sel))
        {
            var _sk_id = ds_map_find_value(global.ap_kakusu_id_by_index,string(_sk_sel));
            if (!is_undefined(_sk_id)
            &&  is_undefined(ds_map_find_value(_scout_seen,real(_sk_id))))
            {
                if (_loc_count > 0) _scout_ids += ",";
                _scout_ids += string(_sk_id);
                _scout_seen[?real(_sk_id)] = 1;
                _loc_count++;
            }
            _sk_sel = ds_map_find_next(global.ap_kakusu_selected,_sk_sel);
        }
    }
    ds_map_destroy(_scout_seen);
    ds_map_destroy(_kak_exclude);
    if (_loc_count == 0)
    {
        var _fi;
        for (_fi = 0; _fi < 168; _fi++)
        {
            if (_fi > 0) _scout_ids += ",";
            _scout_ids += string(387642575169 + _fi);
            _loc_count++;
        }
        show_debug_message("AP: loc id map unavailable, scouting legacy 168-location range");
    }
    _scout_ids += "]";
    apclient_location_scouts(_scout_ids, 0);
    show_debug_message("AP: Scouting " + string(_loc_count) + " locations");

    // Store local player number for cross-world
    global.ap_local_player = apclient_get_player_number();

    // Read DeathLink setting from slot_data
    var _dl = ds_map_find_value(global.ap_slot_data, "death_link");
    global.ap_deathlink_enabled = (!is_undefined(_dl) && _dl == 1);
    if (global.ap_deathlink_enabled)
    {
        // Set DeathLink tag at srv
        apclient_connect_update('["DeathLink"]');
        show_debug_message("AP: DeathLink enabled");
    }
    else
        show_debug_message("AP: DeathLink disabled");
}
