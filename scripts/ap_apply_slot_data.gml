/// ap_apply_slot_data(slot_data_json)
{
    var _slot_data = argument0;
    var _dm = json_decode(_slot_data);
    if (_dm == -1)
    {
        show_debug_message("AP: Failed to parse slot_data (outer JSON too large for GMS 1.4 json_decode)");
        global.ap_slot_data = ds_map_create();
        ap_load_loc_map_from_file();
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

    // Load location_name_to_id from file
    ap_load_loc_map_from_file();

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
