/// ap_generate_hints()
{
    if (!global.AP_connected) exit;
    // Need at least one scouted location.
    if (ds_map_size(global.ap_scouted_flags) < 1) exit;
    if (global.ap_location_data_stale)
    {
        show_debug_message("AP: location data checksum mismatch detected earlier -- skipping hint generation to avoid showing wrong location hints.");
        exit;
    }

    show_debug_message("AP: Generating dynamic hints from scouted data...");

    var _dl_pool, _key, _flags, _loc, _loc_num, _i, _j, _hint_total, _hint_count;
    var _hint_idx, _hint_dk, _player, _item_type, _is_cross, _dialogue, _item_name;
    var _desc, _val, _alias;
    var _dm, _placed;
    var _gi, _hint_pct, _dl_givers, _prev_seed;

    // Collect scouted locations that have prog items
    _dl_pool = ds_list_create();
    _key = ds_map_find_first(global.ap_scouted_flags);
    while (!is_undefined(_key))
    {
        _flags = global.ap_scouted_flags[?_key];
        if (_flags & 1)
            ds_list_add(_dl_pool, _key);
        _key = ds_map_find_next(global.ap_scouted_flags, _key);
    }

    // No progression items? try useful items
    if (ds_list_size(_dl_pool) == 0)
    {
        _key = ds_map_find_first(global.ap_scouted_flags);
        while (!is_undefined(_key))
        {
            _flags = global.ap_scouted_flags[?_key];
            if (_flags & 2)
                ds_list_add(_dl_pool, _key);
            _key = ds_map_find_next(global.ap_scouted_flags, _key);
        }
    }

    if (ds_list_size(_dl_pool) == 0) exit;

    ds_list_shuffle(_dl_pool);

    // How many hint NPCs are available?
    _hint_total = val(g.dm_RandoHints[? STR_Hint + STR_Count]);
    if (_hint_total <= 0)
    {
        ds_list_destroy(_dl_pool);
        exit;
    }

    // hint_giver_percent (apworld option, default 25) thins pool
    _hint_pct = 25;
    if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
    {
        _val = ds_map_find_value(global.ap_slot_data, "hint_giver_percent");
        if (!is_undefined(_val)) _hint_pct = real(_val);
    }
    if (_hint_pct < 0)   _hint_pct = 0;
    if (_hint_pct > 100) _hint_pct = 100;
    _hint_count = min(ceil(_hint_total * _hint_pct / 100), ds_list_size(_dl_pool));

    // Access the save data map: dm_rando is on
    if (!variable_instance_exists(f, "dm_rando"))
    {
        show_debug_message("AP: f.dm_rando not available, can't generate hints");
        exit;
    }
    _dm = f.dm_rando;

    // Clear old hint entries from save data. (1)
    for (_j = 1; _j <= _hint_total; _j++)
    {
        _hint_dk = g.dm_RandoHints[? hex_str(_j) + STR_Dialogue + STR_Datakey];
        if (!is_undefined(_hint_dk))
        {
            ds_map_delete(_dm, STR_Rando + STR_Hint + _hint_dk + STR_Hint + STR_Num);
            ds_map_delete(_dm, STR_Rando + STR_Hint + _hint_dk);
        }
    }
    // (2) Placed-index-keyed entries
    for (_j = 1; _j <= val(_dm[? STR_Rando + STR_Hint + STR_Count]); _j++)
    {
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Dialogue + STR_Datakey);
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Dialogue);
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Item);
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Location);
        // Remote (cross-world) hint target keys written
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Location + "REMOTE");
        ds_map_delete(_dm, STR_Rando + STR_Hint + hex_str(_j) + STR_Location + "OWNER");
    }
    ds_map_delete(_dm, STR_Rando + STR_Hint + STR_Count);
    ds_map_delete(_dm, STR_Zelda + STR_Hint + STR_Dialogue);

    // Choose WHICH hint-givers carry a hint.
    _dl_givers = ds_list_create();
    for (_gi = 1; _gi <= _hint_total; _gi++) ds_list_add(_dl_givers, _gi);
    _prev_seed = random_get_seed();
    if (variable_global_exists("ap_seed") && global.ap_seed != 0) random_set_seed(global.ap_seed);
    ds_list_shuffle(_dl_givers);
    random_set_seed(_prev_seed);

    // Assign hints to NPCs
    _placed = 0;
    for (_i = 0; _i < _hint_count; _i++)
    {
        _loc = real(_dl_pool[|_i]);
        _loc_num = _loc - 387642575169 + 1;
        if (_loc_num < 1 || _loc_num > global.ap_max_loc_num) continue;

        _hint_idx = _dl_givers[| _i]; // random giver index from the shuffled subset
        _hint_dk = g.dm_RandoHints[? hex_str(_hint_idx) + STR_Dialogue + STR_Datakey];
        if (is_undefined(_hint_dk)) continue;

        _player = global.ap_scouted_players[?_loc];
        _item_type = global.ap_scouted_item_types[?_loc];
        _is_cross = (_player != global.ap_local_player);
        _dialogue = "";
        _item_name = "";

        // Location description
        _desc = "";
        if (variable_global_exists("ap_id_to_location_name") && !is_undefined(global.ap_id_to_location_name))
        {
            var _nm = global.ap_id_to_location_name[?_loc];
            if (!is_undefined(_nm) && is_string(_nm) && _nm != "") _desc = string_upper(_nm);
        }
        if (_desc == "")
        {
            _desc = _dm[? STR_Location + hex_str(_loc_num) + STR_Description];
            if (is_undefined(_desc) || !is_string(_desc) || _desc == "")
                _desc = "LOCATION $" + hex_str(_loc_num);
        }

        // Prefer the raw AP item name (e.g. "Boots")
        var _ap_name = global.ap_scouted_item_names[?_loc];
        var _display_name = "";
        if (!is_undefined(_ap_name) && _ap_name != "")
            _display_name = string_upper(_ap_name);
        else if (!is_undefined(_item_type) && _item_type != "")
            _display_name = string_upper(string_letters(_item_type));
        if (_display_name == "") _display_name = "SOMETHING";

        if (_is_cross)
        {
            // "ITEM X IS IN WORLD Y AT LOCATION
            _alias = apclient_get_player_alias(global.ap_local_player);
            if (is_undefined(_alias) || _alias == "") _alias = "PLAYER " + string(global.ap_local_player);
            _dialogue = _display_name + "<IS IN " + string_upper(_alias) + "<AT " + _desc;
            _item_name = "ITEM";
        }
        else
        {
            // "ITEM X IS AT LOCATION Z"
            _dialogue = _display_name + "<IS AT " + _desc;
            if (_display_name != "SOMETHING")
                _item_name = _item_type;
            else
                _item_name = "ITEM";
        }

        // Keep the full, un-truncated hint for later
        var _full = _dialogue;
        // Word-wrap to the dialogue box
        _dialogue = ap_wrap_dialogue(_dialogue);

        // Store in f.dm_rando format
        _placed++;
        _dm[? STR_Rando + STR_Hint + STR_Count] = _placed;
        _dm[? STR_Rando + STR_Hint + hex_str(_placed) + STR_Dialogue + STR_Datakey] = _hint_dk;
        _dm[? STR_Rando + STR_Hint + hex_str(_placed) + STR_Dialogue] = _dialogue;
        _dm[? STR_Rando + STR_Hint + hex_str(_placed) + STR_Item] = _item_name;
        // AP location id this hint reveals
        _dm[? STR_Rando + STR_Hint + hex_str(_placed) + STR_Location] = _loc;
        _dm[? STR_Rando + STR_Hint + _hint_dk + STR_Hint + STR_Num] = _placed;
        _dm[? STR_Rando + STR_Hint + _hint_dk] = _dialogue;
        _dm[? STR_Rando + STR_Hint + hex_str(_placed) + STR_Dialogue + "FULL"] = _full;

        show_debug_message("AP Hint #" + string(_placed) + " [" + string(_hint_dk) + "]: " + _dialogue);
    }

    ds_list_destroy(_dl_pool);

    // NOTE: the Zelda hint is generated separately
    global.ap_hints_generated = true;
    show_debug_message("AP: Generated " + string(_placed) + " dynamic hints");
}
