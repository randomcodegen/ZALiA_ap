/// obj_ap_client_Step()
{
    ap_console_step();

    var _poll_start = current_time;
    var _poll_gap = _poll_start - global.ap_trace_last_poll;
    global.ap_trace_last_poll = _poll_start;
    if (!global.ap_ever_connected && _poll_gap > 250)
        ap_connection_trace("game poll gap=" + string(_poll_gap) + "ms");
    var _script = apclient_poll();
    var _poll_ms = current_time - _poll_start;
    if (_poll_ms > 16) ap_connection_trace("slow DLL poll=" + string(_poll_ms) + "ms");
    if (_script != "{}" && _script != "")
    {
        var _batch_start = current_time;
        var _callback_ms = 0;
        var _event_count = 0;
        var _remaining = _script;
        ap_connection_trace("batch received chars=" + string(string_length(_script))
            + " DLL_poll=" + string(_poll_ms) + "ms");
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
                // Decode the DLL's apostrophe escape in one native pass.
                _j_val = string_replace_all(_raw, "'+"+chr(34)+"'"+chr(34)+"+'", "'");
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

                var _callback_start = current_time;
                _event_count++;
                ap_connection_trace(_func + " begin args_chars=" + string(string_length(_a)));
                if (_func == "ap_room_info") ap_room_info(_a);
                else if (_func == "ap_slot_connected") ap_slot_connected(_a);
                else if (_func == "ap_slot_refused") ap_slot_refused(real(_a));
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
                var _elapsed = current_time - _callback_start;
                _callback_ms += _elapsed;
                ap_connection_trace(_func + " end handler=" + string(_elapsed) + "ms");
            }
        }
        ap_connection_trace("batch done events=" + string(_event_count)
            + " parser=" + string(current_time - _batch_start - _callback_ms)
            + "ms handlers=" + string(_callback_ms) + "ms");
    }

    // Only visible popups age
    if (variable_global_exists("ap_message_timers"))
    {
        var _mt_i;
        for (_mt_i = min(3, ds_list_size(global.ap_message_timers)) - 1; _mt_i >= 0; _mt_i--)
        {
            if (global.ap_message_timers[|_mt_i] > 0)
                global.ap_message_timers[|_mt_i] -= 1;
            if (global.ap_message_timers[|_mt_i] == 0)
            {
                ds_list_delete(global.ap_message_buffer, _mt_i);
                ds_list_delete(global.ap_message_colors, _mt_i);
                ds_list_delete(global.ap_message_timers, _mt_i);
            }
        }
    }

    // Process any items that were deferred until
    if (variable_global_exists("ap_pending_ready") && global.ap_pending_ready
        && variable_global_exists("ap_save_loaded") && global.ap_save_loaded)
    {
        global.ap_pending_ready = false;
        ap_process_pending();
    }

    // Recover boss checks earned before this client build or while disconnected.
    if (global.AP_connected
    &&  variable_global_exists("ap_save_loaded") && global.ap_save_loaded
    && (!variable_global_exists("ap_boss_item_backfill_done")
        || !global.ap_boss_item_backfill_done))
    {
        global.ap_boss_item_backfill_done = true;
        var _bf_on = false;
        if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
        {
            var _bf_opt = ds_map_find_value(global.ap_slot_data, "boss_item_locations");
            _bf_on = !is_undefined(_bf_opt) && real(_bf_opt);
        }
        if (_bf_on)
        {
            var _bf_ids = "[";
            var _bf_count = 0;
            var _bf_dungeon, _bf_id;
            for (_bf_dungeon = 1; _bf_dungeon <= 7; _bf_dungeon++)
            {
                if (_bf_dungeon <= 6)
                {
                    if (!crystal_is_placed(_bf_dungeon)) continue;
                }
                else if (!val(f.dm_quests[?get_defeated_dk()+Area_PalcG+'35'+STR_PRXM+'0']))
                    continue;
                _bf_id = undefined;
                if (variable_global_exists("ap_boss_item_location_ids")
                && !is_undefined(global.ap_boss_item_location_ids))
                    _bf_id = ds_map_find_value(global.ap_boss_item_location_ids,
                        string(_bf_dungeon));
                if (is_undefined(_bf_id)) continue;
                if (variable_global_exists("ap_created_manifest_ready")
                && global.ap_created_manifest_ready
                && is_undefined(ds_map_find_value(global.ap_created_location_ids, real(_bf_id))))
                    continue;
                if (_bf_count > 0) _bf_ids += ",";
                _bf_ids += string(real(_bf_id));
                _bf_count++;
            }
            _bf_ids += "]";
            if (_bf_count > 0)
            {
                apclient_location_checks(_bf_ids);
                show_debug_message("AP: Backfilled " + string(_bf_count)
                    + " boss checks");
            }
        }
    }

    // Some server/client combinations do not emit ap_location_checked for the
    // sending client's own check, so the callback alone is insufficient.
    if (global.AP_connected && variable_global_exists("ap_checked_ids"))
    {
        global.ap_checked_reconcile_timer -= 1;
        if (global.ap_checked_reconcile_timer <= 0)
        {
            global.ap_checked_reconcile_timer = 30;
            var _rc_raw = apclient_get_checked_locations();
            var _rc_key = "global.ap_checked_locations[";
            var _rc_klen = string_length(_rc_key);
            var _rc_seen = ds_map_create();
            var _rc_cap = 256;
            if (variable_global_exists("ap_created_manifest_ready")
            &&  global.ap_created_manifest_ready)
                _rc_cap = ds_map_size(global.ap_created_location_ids) + 16;
            repeat(_rc_cap)
            {
                var _rc_p = string_pos(_rc_key, _rc_raw);
                if (_rc_p == 0) break;
                _rc_raw = string_delete(_rc_raw, 1, _rc_p + _rc_klen - 1);
                var _rc_eq = string_pos("]=", _rc_raw);
                if (_rc_eq == 0) break;
                _rc_raw = string_delete(_rc_raw, 1, _rc_eq + 1);
                var _rc_semi = string_pos(";", _rc_raw);
                if (_rc_semi == 0) break;
                var _rc_id = real(string_copy(_rc_raw, 1, _rc_semi - 1));
                _rc_raw = string_delete(_rc_raw, 1, _rc_semi);
                if (_rc_id > 0) _rc_seen[?_rc_id] = 1;
            }

            var _rc_added = 0;
            var _rc_id_key = ds_map_find_first(_rc_seen);
            while (!is_undefined(_rc_id_key))
            {
                var _rc_real_id = real(_rc_id_key);
                if (ds_list_find_index(global.ap_checked_ids, _rc_real_id) == -1)
                {
                    ds_list_add(global.ap_checked_ids, _rc_real_id);
                    _rc_added++;
                }
                _rc_id_key = ds_map_find_next(_rc_seen, _rc_id_key);
            }
            if (_rc_added > 0)
            {
                ap_refresh_overworld_marks();
                show_debug_message("AP: Reconciled " + string(_rc_added)
                    + " new server-confirmed checks (total "
                    + string(ds_list_size(global.ap_checked_ids)) + ")");
            }
            ds_map_destroy(_rc_seen);
        }
    }

    if (global.ap_pbag_popup_timer > 0 && !global.ap_console_open
    &&  variable_global_exists("pc") && instance_exists(global.pc)
    &&  g.gui_state == g.gui_state_NONE && !g.cutscene)
        global.ap_pbag_popup_timer -= 1;

    // Flush P-Bag XP that was banked while the
    if (variable_global_exists("ap_deferred_xp") && global.ap_deferred_xp > 0
        && variable_global_exists("pc") && global.pc != noone && global.pc.x != 0
        && g.gui_state == g.gui_state_NONE && !g.cutscene
        && !global.ap_console_open)
    {
        var _dxp = global.ap_deferred_xp;
        global.ap_deferred_xp = 0;
        f.xpPending += _dxp;
        f.xpPending &= $FFFF;
        if (global.ap_pbag_popup_timer > 0)
            global.ap_pbag_popup_xp += _dxp;
        else
            global.ap_pbag_popup_xp = _dxp;
        global.ap_pbag_popup_timer = g.XP_RISE_DURATION;
        show_debug_message("AP: Delivered " + string(_dxp) + " banked P-Bag XP to f.xpPending (now " + string(f.xpPending) + ")");
    }

    if (!global.AP_connected && !global.AP_connect_attempted)
    {
        var _pw = "(none)";
        if (string_length(global.ap_password) > 0) _pw = "***";
        show_debug_message("AP connect — server: " + global.ap_server + ", slot: " + global.ap_slot + ", password: " + _pw);
        ap_connection_trace("connect request begin");
        apclient_connect("", "ZALiA", global.ap_server);
        ap_connection_trace("connect request returned");
        apclient_set_items_handling(7);
        apclient_set_version(0, 6, 8);
        global.AP_connect_attempted = true;
        global.ap_connect_started = current_time;
    }

    // Auto-login to slot once room info is
    if (apclient_get_state() == global.AP_STATE_ROOM_INFO
    &&  !global.AP_slot_connect_attempted)
    {
        global.AP_slot_connect_attempted = true;
        ap_connection_trace("slot login request begin");
        apclient_connect_slot(global.ap_slot, global.ap_password, "[]");
        ap_connection_trace("slot login request returned");
    }

    // End connection attempt. /connect starts the next one.
    if (!global.AP_connected && !global.ap_console_failure_shown
    &&  global.AP_connect_attempted && global.ap_connect_started > 0
    &&  current_time - global.ap_connect_started >= 15000)
    {
        apclient_disconnect();
        global.ap_connect_started = 0;
        global.AP_slot_connect_attempted = false;
        global.ap_console_failure_shown = true;
        if (!global.ap_console_open)
        {
            keyboard_string = "";
            ds_list_clear(global.ap_console_matches);
            global.ap_console_completion_input = "";
            global.ap_console_match_index = -1;
            global.ap_console_suggestion = "";
        }
        global.ap_console_open = true;
        var _error = "AP ERROR: CONNECTION TIMED OUT. USE /CONNECT TO RETRY.";
        if (global.AP_last_error != "")
            _error += " LAST SOCKET ERROR: " + string(global.AP_last_error);
        ap_console_add(_error, "");
    }
}
