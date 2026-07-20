/// obj_ap_client_Step()
{
    var _script = apclient_poll();
    if (_script != "{}" && _script != "")
    {
        var _remaining = _script;
        var _semi_pos, _block, _eq, _j_val;
        _j_val = "";

        while (string_length(_remaining) > 0)
        {
            _semi_pos = string_pos(";", _remaining);
            if (_semi_pos == 0) break;

            _block = string_copy(_remaining, 1, _semi_pos - 1);
            _remaining = string_delete(_remaining, 1, _semi_pos);

            // Strip leading junk (#, LF, CR, {, }, space)
            while (string_length(_block) > 0)
            {
                var _c = string_char_at(_block, 1);
                if (_c == "#" || _c == "{" || _c == "}" || _c == " " || ord(_c) == 10 || ord(_c) == 13)
                { _block = string_delete(_block, 1, 1); }
                else break;
            }
            // Strip trailing junk
            while (string_length(_block) > 0)
            {
                var _c = string_char_at(_block, string_length(_block));
                if (_c == "#" || _c == "{" || _c == "}" || _c == " " || ord(_c) == 10 || ord(_c) == 13)
                { _block = string_delete(_block, string_length(_block), 1); }
                else break;
            }

            // Variable assignment: varname = '...'
            _eq = string_pos(" = '", _block);
            if (_eq > 0)
            {
                var _raw = string_copy(_block, _eq + 4, string_length(_block) - _eq - 4);
                var _pos = 1;
                _j_val = "";
                while (_pos <= string_length(_raw))
                {
                    if (_pos + 6 <= string_length(_raw) && string_char_at(_raw, _pos) == "'" && string_char_at(_raw, _pos + 1) == "+")
                    {
                        _j_val += "'";
                        _pos += 7;
                    }
                    else
                    {
                        _j_val += string_char_at(_raw, _pos);
                        _pos += 1;
                    }
                }
                continue;
            }

            // Array assignment: global.varname[idx]=val
            if (string_pos("global.", _block) == 1)
            {
                var _bracket = string_pos("[", _block);
                if (_bracket > 0)
                {
                    var _eq = string_pos("]=", _block);
                    var _val_start = 0;
                    if (_eq > 0)
                        _val_start = _eq + 2;
                    else
                    {
                        _eq = string_pos("] = ", _block);
                        if (_eq > 0) _val_start = _eq + 4;
                    }
                    if (_val_start > 0)
                    {
                        var _arr = string_copy(_block, 8, _bracket - 8);
                        var _idx = real(string_copy(_block, _bracket + 1, _eq - _bracket - 1));
                        var _val = string_copy(_block, _val_start, string_length(_block) - _val_start + 1);
                        if (string_char_at(_val, 1) == "'" && string_char_at(_val, string_length(_val)) == "'")
                            _val = string_copy(_val, 2, string_length(_val) - 2);
                        if (_arr == "arg_ids") global.arg_ids[_idx] = real(_val);
                        else if (_arr == "arg_names") global.arg_names[_idx] = _val;
                        else if (_arr == "arg_items") global.arg_items[_idx] = real(_val);
                        else if (_arr == "arg_flags") global.arg_flags[_idx] = real(_val);
                        else if (_arr == "arg_players") global.arg_players[_idx] = real(_val);
                        else if (_arr == "arg_locations") global.arg_locations[_idx] = real(_val);
                else if (_arr == "arg_errors") global.arg_errors[_idx] = _val;
                        continue;
                    }
                }
            }

            // Function call: func(args)
            var _paren = string_pos("(", _block);
            if (_paren > 0)
            {
                var _func = string_copy(_block, 1, _paren - 1);
                var _a = string_copy(_block, _paren + 1, string_length(_block) - _paren - 1);
                if (_a == "j") _a = _j_val;

                while (string_length(_func) > 0 && string_char_at(_func, string_length(_func)) == "#")
                    _func = string_delete(_func, string_length(_func), 1);

                if (_func == "ap_room_info") ap_room_info(_a);
                else if (_func == "ap_slot_connected") ap_slot_connected(_a);
                else if (_func == "ap_slot_refused") ap_slot_refused();
                else if (_func == "ap_socket_connected") ap_socket_connected();
                else if (_func == "ap_socket_disconnected") ap_socket_disconnected();
                else if (_func == "ap_socket_error") ap_socket_error(_a);
                else if (_func == "ap_items_received")
                {
                    var _comma = string_pos(", ", _a);
                    ap_items_received(real(string_copy(_a, 1, _comma - 1)), real(string_copy(_a, _comma + 2, string_length(_a) - _comma - 1)));
                }
                else if (_func == "ap_location_info") ap_location_info(real(_a));
                else if (_func == "ap_location_checked") ap_location_checked(real(_a));
                else if (_func == "ap_print_json") ap_print_json(_a);
                else if (_func == "ap_bounced") ap_bounced(_a);
            }
        }
    }

    // Tick per-message display timers; remove expired
    if (variable_global_exists("ap_message_timers"))
    {
        var _mt_i;
        var _mt_sz = ds_list_size(global.ap_message_timers);
        for (_mt_i = 0; _mt_i < _mt_sz; _mt_i++)
            global.ap_message_timers[|_mt_i] -= 1;
        while (ds_list_size(global.ap_message_timers) > 0
            && global.ap_message_timers[|0] <= 0)
        {
            ds_list_delete(global.ap_message_buffer, 0);
            ds_list_delete(global.ap_message_timers, 0);
        }
    }

    // Process any items that were deferred until
    if (variable_global_exists("ap_pending_ready") && global.ap_pending_ready
        && variable_global_exists("ap_save_loaded") && global.ap_save_loaded)
    {
        global.ap_pending_ready = false;
        ap_process_pending();
    }

    // Flush P-Bag XP that was banked while the
    if (variable_global_exists("ap_deferred_xp") && global.ap_deferred_xp > 0
        && variable_global_exists("pc") && global.pc != noone && global.pc.x != 0
        && g.gui_state == g.gui_state_NONE && !g.cutscene)
    {
        var _dxp = global.ap_deferred_xp;
        global.ap_deferred_xp = 0;
        f.xpPending += _dxp;
        f.xpPending &= $FFFF;
        show_debug_message("AP: Delivered " + string(_dxp) + " banked P-Bag XP to f.xpPending (now " + string(f.xpPending) + ")");
    }

    if (!global.AP_connected && !global.AP_connect_attempted)
    {
        var _pw = "(none)";
        if (string_length(global.ap_password) > 0) _pw = "***";
        show_debug_message("AP connect — server: " + global.ap_server + ", slot: " + global.ap_slot + ", password: " + _pw);
        apclient_connect("", "ZALiA", global.ap_server);
        apclient_set_items_handling(7);
        apclient_set_version(0, 6, 8);
        global.AP_connect_attempted = true;
    }

    // Auto-login to slot once room info is
    if (apclient_get_state() == global.AP_STATE_ROOM_INFO && !global.AP_connected)
    {
        apclient_connect_slot(global.ap_slot, global.ap_password, "[]");
    }

    // Exit on initial conn failure, but not
    if (global.AP_error_time > 0 && !global.ap_ever_connected)
    {
        global.AP_error_time -= 1;
        if (global.AP_error_time == 0 && !global.AP_connected)
        {
            show_message("Archipelago connection failed: " + global.AP_last_error + "#The game will now close.");
            game_end();
        }
    }
}
