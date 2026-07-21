/// ap_check_spell_location()
{
    if (!global.AP_connected) { show_debug_message("AP_SPELL: not connected"); return true; }
    if (!variable_global_exists("AP_location_map")) { show_debug_message("AP_SPELL: no AP_location_map"); return true; }
    if (!variable_global_exists("ap_scouted_item_types")) { show_debug_message("AP_SPELL: no scouted types"); return true; }

    var _give_spell = g.dialogue_source.give_spell;
    show_debug_message("AP_SPELL: give_spell bit = $" + hex_str(_give_spell));
    if (_give_spell == 0) return true;

    // Convert spell bit to GML item name
    var _item_id = val(g.dm_Spell[?hex_str(_give_spell) + STR_Name], "");
    show_debug_message("AP_SPELL: item_id = '" + string(_item_id) + "'");
    if (_item_id == "") return true;

    // Look up spawn datakey for this spell
    var _spawn_datakey = val(g.dm_spawn[?STR_Spell+STR_Spawn+STR_Datakey+_item_id], "");
    show_debug_message("AP_SPELL: spawn_datakey = '" + string(_spawn_datakey) + "'");
    if (_spawn_datakey == "") return true;

    // Look up AP location ID for this spell
    var _ap_id = global.AP_location_map[?_spawn_datakey];
    show_debug_message("AP_SPELL: ap_id = " + string(_ap_id));
    if (is_undefined(_ap_id)) return true;

    // Already checked on the AP srv? Don't grant
    if (ds_list_find_index(global.ap_checked_ids, _ap_id) != -1)
    {
        show_debug_message("AP_SPELL: already checked, skipping local grant");
        return false;
    }

    show_debug_message("AP_SPELL: sending check, skipping local grant");
    apclient_location_checks("[" + string(_ap_id) + "]");
    return false; // skip local grant, srv sends item
}
