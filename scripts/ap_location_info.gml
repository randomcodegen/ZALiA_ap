/// ap_location_info(count)
{
    var _count = argument0;
    var _i;
    for (_i = 0; _i < _count; _i++)
    {
        var _loc = global.arg_locations[_i];
        var _flags = global.arg_flags[_i];
        var _player = global.arg_players[_i];
        var _item = global.arg_items[_i];

        global.ap_scouted_flags[?_loc] = _flags;
        global.ap_scouted_players[?_loc] = _player;
        global.ap_scouted_item_ids[?_loc] = _item;

        // Look up item name using the owning player's game
        var _player_game = apclient_get_player_game(_player);
        var _item_name = apclient_get_item_name(_item, _player_game);
        if (_item_name == "" || _item_name == "Unknown")
            _item_name = apclient_get_item_name(_item, "ZALiA"); // fallback for local items
        show_debug_message("AP: Scout loc=" + string(_loc) + " itemID=" + string(_item) + " name='" + string(_item_name) + "' flags=" + string(_flags) + " player=" + string(_player));

        // Store raw AP name for hint generation
        if (_item_name != "" && _item_name != "Unknown")
            global.ap_scouted_item_names[?_loc] = _item_name;

        if (_item_name != "" && _item_name != "Unknown")
        {
            var _gml_name = ap_name_to_gml(_item_name);
            if (_gml_name != "")
            {
                global.ap_scouted_item_types[?_loc] = _gml_name;
                var _spr = val(g.dm_ITEM[?_gml_name+STR_Sprite], -1);
                // Palace-specific key names (e.g. "_KEY04")
                if (_spr == -1 && string_pos(STR_KEY, _gml_name) == 1)
                    _spr = val(g.dm_ITEM[?STR_KEY+STR_Sprite], -1);
                if (_spr > 0) global.ap_scouted_sprites[?_loc] = _spr;
            }
        }
    }

    // Generate dynamic hints once the scout responses are done
    if (!global.ap_hints_generated && ds_map_size(global.ap_scouted_flags) >= 1)
    {
        show_debug_message("AP: Scouts cached (" + string(ds_map_size(global.ap_scouted_flags)) + "), generating dynamic hints...");
        // NPC item-location hints. May early-exit if none
        ap_generate_hints();
        // Zelda hint is generated independently
        ap_generate_zelda_hint();
        global.ap_hints_generated = true;
    }

    show_debug_message("AP: Scouting cached for " + string(_count) + " locations (total cached: " + string(ds_map_size(global.ap_scouted_flags)) + ")");
}
