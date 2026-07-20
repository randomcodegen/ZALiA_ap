/// ap_generate_zelda_hint()
{
    if (!global.AP_connected) exit;

    // Determine the Zelda-hint mode. Prefer AP slot_data
    var _zelda_mode = -1;
    if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
    {
        var _sd_mode = ds_map_find_value(global.ap_slot_data, "zelda_hint");
        if (!is_undefined(_sd_mode)) _zelda_mode = real(_sd_mode);
    }
    if (_zelda_mode < 0) _zelda_mode = val(global.dm_save_file_settings[? STR_Zelda + STR_Hint]);
    if (_zelda_mode <= 0)
    {
        show_debug_message("AP: Zelda hint mode=" + string(_zelda_mode) + " (off), skipping Zelda hint");
        exit;
    }

    if (!variable_instance_exists(f, "dm_rando"))
    {
        show_debug_message("AP: f.dm_rando not available, can't generate Zelda hint");
        exit;
    }
    var _dm = f.dm_rando;

    var _target_item = "";
    var _dialogue = "";
    var _item_name = "";
    var _key, _item_type, _player, _desc, _val;
    // When the target is placed in ANOTHER world
    var _remote_locid  = -1;
    var _remote_player = -1;

    switch (_zelda_mode)
    {
        case 1: _target_item = STR_FLUTE; break;
        case 2: _target_item = STR_ALLKEY; break;
        case 3: _target_item = STR_JUMP; break;
        default: exit;
    }

    // Search scouted locations for the target item
    _key = ds_map_find_first(global.ap_scouted_flags);
    while (!is_undefined(_key))
    {
        _item_type = global.ap_scouted_item_types[?_key];
        if (!is_undefined(_item_type) && _item_type == _target_item)
        {
            _key = real(_key);
            break;
        }
        _key = ds_map_find_next(global.ap_scouted_flags, _key);
    }

    if (is_undefined(_key))
    {
        // The target item is not at any of the local locs
        var _sd_ok = false;
        if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data)
            && ds_exists(global.ap_slot_data, ds_type_map))
        {
            var _sd_text = ds_map_find_value(global.ap_slot_data, "zelda_hint_text");
            var _sd_item = ds_map_find_value(global.ap_slot_data, "zelda_hint_item");
            var _sd_loc  = ds_map_find_value(global.ap_slot_data, "zelda_hint_location");
            var _sd_ply  = ds_map_find_value(global.ap_slot_data, "zelda_hint_player");
            var _sd_locid = ds_map_find_value(global.ap_slot_data, "zelda_hint_location_id");

            // Capture the location id + owning slot
            if (!is_undefined(_sd_locid) && !is_undefined(_sd_ply))
            {
                _remote_locid  = real(_sd_locid);
                _remote_player = real(_sd_ply);
            }

            if (!is_undefined(_sd_text) && is_string(_sd_text) && _sd_text != "")
            {
                _dialogue = _sd_text;
                _item_name = _target_item;
                _sd_ok = true;
            }
            else if (!is_undefined(_sd_loc) && is_string(_sd_loc) && _sd_loc != "")
            {
                var _sd_disp = "";
                if (!is_undefined(_sd_item) && is_string(_sd_item) && _sd_item != "")
                    _sd_disp = string_upper(_sd_item);
                else
                    _sd_disp = string_upper(string_letters(_target_item));
                if (_sd_disp == "") _sd_disp = "SOMETHING";

                var _sd_locname = string_upper(_sd_loc);

                var _sd_is_cross = false;
                if (!is_undefined(_sd_ply))
                    _sd_is_cross = (real(_sd_ply) != global.ap_local_player);

                if (_sd_is_cross)
                {
                    var _sd_alias = apclient_get_player_alias(real(_sd_ply));
                    if (is_undefined(_sd_alias) || _sd_alias == "")
                        _sd_alias = "PLAYER " + string(real(_sd_ply));
                    _dialogue = _sd_disp + "<IS IN " + string_upper(_sd_alias) + "<AT " + _sd_locname;
                }
                else
                {
                    _dialogue = _sd_disp + "<IS AT " + _sd_locname;
                }
                _item_name = _target_item;
                _sd_ok = true;
            }
        }

        if (!_sd_ok)
        {
            // No apworld fallback available -- stay honest
            _dialogue = "I CANNOT<SEE THAT<ITEM FROM<HERE.";
            _item_name = _target_item;
        }
    }
    else
    {
        _player = global.ap_scouted_players[?_key];

        // Location description
        var _loc_num = _key - 387642575169 + 1;
        _desc = "";
        if (variable_global_exists("ap_id_to_location_name") && !is_undefined(global.ap_id_to_location_name))
        {
            var _nm = global.ap_id_to_location_name[?_key];
            if (!is_undefined(_nm) && is_string(_nm) && _nm != "") _desc = string_upper(_nm);
        }
        if (_desc == "")
        {
            _desc = _dm[? STR_Location + hex_str(_loc_num) + STR_Description];
            if (is_undefined(_desc) || !is_string(_desc) || _desc == "")
                _desc = "LOCATION $" + hex_str(_loc_num);
        }

        var _ap_name = global.ap_scouted_item_names[?_key];
        var _display_name = "";
        if (!is_undefined(_ap_name) && _ap_name != "")
            _display_name = string_upper(_ap_name);
        else
            _display_name = string_upper(string_letters(_target_item));
        if (_display_name == "") _display_name = "SOMETHING";

        if (_player != global.ap_local_player)
        {
            // "ITEM X IS IN WORLD Y AT LOCATION
            var _alias = apclient_get_player_alias(global.ap_local_player);
            if (is_undefined(_alias) || _alias == "") _alias = "PLAYER " + string(global.ap_local_player);
            _dialogue = _display_name + "<IS IN " + string_upper(_alias) + "<AT " + _desc;
            _item_name = _target_item;
        }
        else
        {
            // "ITEM X IS AT LOCATION Z"
            _dialogue = _display_name + "<IS AT " + _desc;
            _item_name = _target_item;
        }
    }

    // Keep the full, un-truncated hint
    var _full = _dialogue;
    // Word-wrap to the dialogue box
    _dialogue = ap_wrap_dialogue(_dialogue);

    // Store Zelda hint in save data format
    if (_dialogue != "")
    {
        var _count = val(_dm[? STR_Rando + STR_Hint + STR_Count]) + 1;
        _dm[? STR_Rando + STR_Hint + STR_Count] = _count;
        _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Dialogue + STR_Datakey] = STR_Zelda + STR_Hint;
        _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Dialogue] = _dialogue;
        _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Item] = _item_name;
        // AP location id this hint reveals
        if (!is_undefined(_key))
            _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Location] = _key;
        // Remote (cross-world) target: no local location
        else if (_remote_locid > 0 && _remote_player > 0)
        {
            _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Location + "REMOTE"] = _remote_locid;
            _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Location + "OWNER"]  = _remote_player;
        }
        _dm[? STR_Rando + STR_Hint + STR_Zelda + STR_Hint + STR_Hint + STR_Num] = _count;
        _dm[? STR_Rando + STR_Hint + STR_Zelda + STR_Hint] = _dialogue;
        _dm[? STR_Zelda + STR_Hint + STR_Dialogue] = _dialogue;
        _dm[? STR_Rando + STR_Hint + hex_str(_count) + STR_Dialogue + "FULL"] = _full;

        show_debug_message("AP Zelda Hint: " + _dialogue);
    }
}
