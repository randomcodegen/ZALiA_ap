/// ap_apply_slot_data(slot_data_json)
{
    var _slot_data = argument0;
    global.ap_created_manifest_error = false;
    var _dm = json_decode(_slot_data);
    if (_dm == -1)
    {
        show_debug_message("AP: Failed to parse slot_data (outer JSON too large for GMS 1.4 json_decode)");
        global.ap_slot_data = ds_map_create();
        global.ap_created_manifest_error = true;
        exit;
    }

    show_debug_message("AP: slot_data parsed successfully");

    global.ap_slot_data = _dm;

    // Read the per-player seed from slot_data
    var _seed_val = ds_map_find_value(_dm, "seed");
    if (!is_undefined(_seed_val))
    {
        global.ap_seed = _seed_val;
        show_debug_message("AP: seed from slot_data = " + string(global.ap_seed));
    }
    else
    {
        // Fallback: use apclient_get_seed (multiworld seed)
        var _seed_str = apclient_get_seed();
        global.ap_seed = real(_seed_str);
        show_debug_message("AP: seed fallback (multiworld) = " + string(global.ap_seed));
    }

    // AP server holds info on which locations exist in this seed. 
    // Each hex character represents four consecutive location_num values,
    // bit 0 is the first location in that group.
    ds_map_clear(global.ap_created_location_ids);
    ds_map_clear(global.ap_created_location_indices);
    global.ap_created_manifest_ready = false;
    global.ap_location_manifest_version = 0;
    var _manifest_ver = ds_map_find_value(_dm, "location_manifest_version");
    var _manifest_bits = ds_map_find_value(_dm, "created_location_bits");
    var _catalog_size = ds_map_find_value(_dm, "location_catalog_size");
    if (!is_undefined(_manifest_ver) && !is_undefined(_manifest_bits)
    &&  !is_undefined(_catalog_size) && real(_manifest_ver) >= 1)
    {
        global.ap_location_manifest_version = real(_manifest_ver);
        var _manifest_len = string_length(string(_manifest_bits));
        var _manifest_i;
        for (_manifest_i = 0; _manifest_i < real(_catalog_size); _manifest_i++)
        {
            var _char_pos = floor(_manifest_i / 4) + 1;
            if (_char_pos > _manifest_len) break;
            var _nibble = ap_hex_val(string_char_at(string(_manifest_bits), _char_pos));
            var _bit_value = power(2, _manifest_i mod 4);
            if ((floor(_nibble / _bit_value) mod 2) == 1)
            {
                var _location_num = _manifest_i + 1;
                var _location_id = 387642575169 + _manifest_i;
                global.ap_created_location_indices[?_location_num] = _location_id;
                global.ap_created_location_ids[?_location_id] = _location_num;
            }
        }
        global.ap_created_manifest_ready = true;
        ap_build_location_catalog_maps();
        show_debug_message("AP: authoritative location manifest loaded ("
            + string(ds_map_size(global.ap_created_location_ids)) + " created of "
            + string(_catalog_size) + ")");
    }
    else
    {
        global.ap_created_manifest_error = true;
        show_debug_message("AP: slot rejected: authoritative location manifest is missing");
    }

    // Boss checks are virtual locations and are not part of the native GML
    // location table. Carry their authoritative AP ids in slot data.
    if (variable_global_exists("ap_boss_item_location_ids")
    && !is_undefined(global.ap_boss_item_location_ids)
    && ds_exists(global.ap_boss_item_location_ids, ds_type_map))
        ds_map_destroy(global.ap_boss_item_location_ids);
    global.ap_boss_item_location_ids = undefined;
    var _boss_ids_json = ds_map_find_value(_dm, "boss_item_location_ids");
    if (!is_undefined(_boss_ids_json))
    {
        var _boss_ids_map = json_decode(_boss_ids_json);
        if (_boss_ids_map != -1) global.ap_boss_item_location_ids = _boss_ids_map;
        else show_debug_message("AP: failed to parse boss_item_location_ids");
    }

    // Stash the apworld's location data checksum
    var _checksum_val = ds_map_find_value(_dm, "location_data_checksum");
    global.ap_slotdata_location_checksum = "";
    if (!is_undefined(_checksum_val)) global.ap_slotdata_location_checksum = _checksum_val;

    // Spell-sequence puzzles (Kings Tomb, Carock 2, etc.)
    if (variable_global_exists("ap_spell_sequences")
    && !is_undefined(global.ap_spell_sequences)
    &&  ds_exists(global.ap_spell_sequences, ds_type_map))
    {
        ds_map_destroy(global.ap_spell_sequences);
    }
    global.ap_spell_sequences = undefined;
    var _seq_json = ds_map_find_value(_dm, "spell_sequences");
    if (!is_undefined(_seq_json))
    {
        var _seq_map = json_decode(_seq_json);
        if (_seq_map != -1) global.ap_spell_sequences = _seq_map;
        else show_debug_message("AP: failed to parse spell_sequences");
    }

    // Randomly-selected individual Kakusu indices (per seed)
    if (variable_global_exists("ap_kakusu_selected") && !is_undefined(global.ap_kakusu_selected)
    &&  ds_exists(global.ap_kakusu_selected, ds_type_map))
    {
        ds_map_destroy(global.ap_kakusu_selected);
    }
    global.ap_kakusu_selected = undefined;
    var _kak_json = ds_map_find_value(_dm, "kakusu_selected_indices");
    if (!is_undefined(_kak_json))
    {
        var _kak_map = json_decode(_kak_json);
        if (_kak_map != -1) global.ap_kakusu_selected = _kak_map;
        else show_debug_message("AP: failed to parse kakusu_selected_indices");
    }

    // Authoritative town/dungeon shuffle layouts (content -> tile)
    if (variable_global_exists("ap_town_position") && !is_undefined(global.ap_town_position)
    &&  ds_exists(global.ap_town_position, ds_type_map))
    {
        ds_map_destroy(global.ap_town_position);
    }
    global.ap_town_position = undefined;
    var _twn_json = ds_map_find_value(_dm, "town_position");
    if (!is_undefined(_twn_json))
    {
        var _twn_map = json_decode(_twn_json);
        if (_twn_map != -1) global.ap_town_position = _twn_map;
        else show_debug_message("AP: failed to parse town_position");
    }

    if (variable_global_exists("ap_dungeon_position") && !is_undefined(global.ap_dungeon_position)
    &&  ds_exists(global.ap_dungeon_position, ds_type_map))
    {
        ds_map_destroy(global.ap_dungeon_position);
    }
    global.ap_dungeon_position = undefined;
    var _dng_json = ds_map_find_value(_dm, "dungeon_position");
    if (!is_undefined(_dng_json))
    {
        var _dng_map = json_decode(_dng_json);
        if (_dng_map != -1) global.ap_dungeon_position = _dng_map;
        else show_debug_message("AP: failed to parse dungeon_position");
    }
}
