/// ap_console_step()
{
    if (keyboard_check_pressed(vk_f1))
    {
        global.ap_console_open = !global.ap_console_open;
        global.ap_console_scroll = 0;
        global.ap_console_history_index = -1;
        global.ap_console_history_draft = "";
        global.ap_console_suggestion = "";
        ds_list_clear(global.ap_console_matches);
        global.ap_console_completion_input = "";
        global.ap_console_match_index = -1;
        keyboard_string = "";
        keyboard_clear(vk_f1);
        exit;
    }
    if (!global.ap_console_open) exit;

    if (keyboard_check_pressed(vk_escape))
    {
        global.ap_console_open = false;
        global.ap_console_scroll = 0;
        global.ap_console_history_index = -1;
        global.ap_console_history_draft = "";
        global.ap_console_suggestion = "";
        ds_list_clear(global.ap_console_matches);
        global.ap_console_completion_input = "";
        global.ap_console_match_index = -1;
        keyboard_string = "";
        keyboard_clear(vk_escape);
        exit;
    }

    if (string_length(keyboard_string) > 200)
        keyboard_string = string_copy(keyboard_string, 1, 200);

    var _history_count = ds_list_size(global.ap_console_history);
    var _history_changed = false;
    if (keyboard_check_pressed(vk_up) && _history_count > 0)
    {
        if (global.ap_console_history_index < 0)
        {
            global.ap_console_history_draft = keyboard_string;
            global.ap_console_history_index = _history_count - 1;
        }
        else if (global.ap_console_history_index > 0)
            global.ap_console_history_index -= 1;
        keyboard_string = global.ap_console_history[|global.ap_console_history_index];
        _history_changed = true;
    }
    if (keyboard_check_pressed(vk_down) && global.ap_console_history_index >= 0)
    {
        if (global.ap_console_history_index < _history_count - 1)
        {
            global.ap_console_history_index += 1;
            keyboard_string = global.ap_console_history[|global.ap_console_history_index];
        }
        else
        {
            global.ap_console_history_index = -1;
            keyboard_string = global.ap_console_history_draft;
        }
        _history_changed = true;
    }
    if (_history_changed)
    {
        ds_list_clear(global.ap_console_matches);
        global.ap_console_completion_input = "";
        global.ap_console_match_index = -1;
        global.ap_console_suggestion = "";
    }

    var _scroll = 0;
    if (keyboard_check_pressed(vk_pageup) || keyboard_check_pressed(vk_pagedown))
    {
        var _lineH = sprite_get_height(global.dl_game_font[|global.game_font_idx]) + 2;
        var _page = max(1, floor((viewH() - 11 - 5 * _lineH) / _lineH));
        if (keyboard_check_pressed(vk_pageup)) _scroll = _page;
        else _scroll = -_page;
    }
    global.ap_console_scroll = max(0, global.ap_console_scroll + _scroll);

    if (keyboard_string != global.ap_console_completion_input)
    {
        ds_list_clear(global.ap_console_matches);
        global.ap_console_match_index = -1;
        global.ap_console_completion_input = keyboard_string;

        var _input = string_upper(keyboard_string);
        var _space = string_pos(" ", _input);
        var _i, _name, _query, _source, _head, _pass;
        if (_space == 0 && string_length(_input) > 0
        && (string_char_at(_input, 1) == "!"
        ||  string_char_at(_input, 1) == "/"))
        {
            if (_input == "!HINT" || _input == "!HINT_LOCATION"
            ||  _input == "/HOST" || _input == "/SLOT"
            ||  _input == "/PASSWORD")
                ds_list_add(global.ap_console_matches, _input + " ");
            else
            {
                for (_i = 0; _i < ds_list_size(global.ap_console_commands); _i++)
                {
                    _name = global.ap_console_commands[|_i];
                    if (string_copy(_name, 1, string_length(_input)) == _input
                    &&  _name != _input)
                        ds_list_add(global.ap_console_matches, _name);
                }
            }
        }
        else if (_space > 0)
        {
            _head = string_copy(keyboard_string, 1, _space - 1);
            _query = string_copy(_input, _space + 1, string_length(_input));
            _source = -1;
            if (string_upper(_head) == "!HINT") _source = global.ap_console_items;
            if (string_upper(_head) == "!HINT_LOCATION") _source = global.ap_console_locations;
            if (_source != -1)
            {
                for (_pass = 0; _pass < 2; _pass++)
                {
                    for (_i = 0; _i < ds_list_size(_source); _i++)
                    {
                        _name = _source[|_i];
                        var _upper_name = string_upper(_name);
                        var _starts = string_copy(_upper_name, 1, string_length(_query)) == _query;
                        if ((_pass == 0 && _starts)
                        ||  (_pass == 1 && !_starts && _query != ""
                        &&   string_pos(_query, _upper_name) > 0))
                            ds_list_add(global.ap_console_matches, _head + " " + _name);
                    }
                }
            }
        }
    }

    global.ap_console_suggestion = "";
    if (ds_list_size(global.ap_console_matches) > 0)
    {
        var _next = (global.ap_console_match_index + 1) mod ds_list_size(global.ap_console_matches);
        global.ap_console_suggestion = global.ap_console_matches[|_next];
    }

    if (keyboard_check_pressed(vk_tab))
    {
        if (global.ap_console_suggestion != "")
        {
            keyboard_string = global.ap_console_suggestion;
            global.ap_console_match_index = _next;
            global.ap_console_completion_input = keyboard_string;
            if (keyboard_string == "!HINT " || keyboard_string == "!HINT_LOCATION "
            ||  keyboard_string == "/HOST " || keyboard_string == "/SLOT "
            ||  keyboard_string == "/PASSWORD ")
                global.ap_console_completion_input = "";
            _next = (_next + 1) mod ds_list_size(global.ap_console_matches);
            global.ap_console_suggestion = global.ap_console_matches[|_next];
        }
        exit;
    }

    if (keyboard_check_pressed(vk_enter))
    {
        global.ap_console_scroll = 0;
        var _line = keyboard_string;
        while (string_length(_line) > 0 && string_char_at(_line, 1) == " ")
            _line = string_delete(_line, 1, 1);
        global.ap_console_history_index = -1;
        global.ap_console_history_draft = "";
        keyboard_string = "";
        global.ap_console_suggestion = "";
        ds_list_clear(global.ap_console_matches);
        global.ap_console_completion_input = "";
        global.ap_console_match_index = -1;
        if (_line == "") exit;

        var _history_head = _line;
        var _history_space = string_pos(" ", _line);
        if (_history_space > 0)
            _history_head = string_copy(_line, 1, _history_space - 1);
        if (string_upper(_history_head) != "/PASSWORD")
        {
            ds_list_add(global.ap_console_history, _line);
            if (ds_list_size(global.ap_console_history) > 2048)
                ds_list_delete(global.ap_console_history, 0);
        }

        if (string_char_at(_line, 1) == "/")
        {
            var _space = string_pos(" ", _line);
            var _command = string_upper(_line);
            var _value = "";
            if (_space > 0)
            {
                _command = string_upper(string_copy(_line, 1, _space - 1));
                _value = string_copy(_line, _space + 1, string_length(_line));
            }

            var _save = false;
            var _retry = false;
            if (_command == "/HOST")
            {
                if (_value == "")
                    ap_console_add("HOST: " + global.ap_server + "  USE /HOST ADDRESS", "");
                else if (string_pos(" ", _value) > 0 || string_pos(chr(9), _value) > 0
                || (string_pos("://", _value) > 0
                && (string_length(_value) <= string_pos("://", _value) + 2
                || (string_copy(_value, 1, string_pos("://", _value) - 1) != "ws"
                &&  string_copy(_value, 1, string_pos("://", _value) - 1) != "wss"))))
                    ap_console_add("USE HOST:PORT, ws://HOST:PORT, OR wss://HOST:PORT", "");
                else
                {
                    global.ap_server = _value;
                    ap_console_add("HOST SET: " + _value + ". USE /CONNECT.", "");
                    _save = true;
                }
            }
            else if (_command == "/SLOT")
            {
                if (_value == "")
                    ap_console_add("SLOT: " + global.ap_slot + "  USE /SLOT NAME", "");
                else
                {
                    global.ap_slot = _value;
                    ap_console_add("SLOT SET: " + _value + ". USE /CONNECT.", "");
                    _save = true;
                }
            }
            else if (_command == "/PASSWORD")
            {
                global.ap_password = _value;
                ap_console_add("PASSWORD UPDATED. USE /CONNECT.", "");
                _save = true;
            }
            else if (_command == "/CONNECT")
                _retry = true;
            else
                ap_console_add("UNKNOWN LOCAL COMMAND", "");

            if (_save)
            {
                ini_open(global.ap_config_path);
                ini_write_string("Connection", "server", global.ap_server);
                ini_write_string("Connection", "slot", global.ap_slot);
                ini_write_string("Connection", "password", global.ap_password);
                ini_close();
            }
            if (_save || _retry)
            {
                apclient_disconnect();
                global.AP_connected = false;
                global.AP_connect_attempted = true;
                if (_retry) global.AP_connect_attempted = false;
                global.AP_slot_connect_attempted = false;
                global.ap_connect_started = 0;
                global.AP_last_error = "";
                global.ap_console_failure_shown = false;
                if (_retry)
                    ap_console_add("CONNECTING TO " + global.ap_server + " AS " + global.ap_slot, "");
            }
        }
        else
        {
            ap_console_add("YOU: " + _line, "");
            if (!global.AP_connected)
                ap_console_add("AP IS NOT CONNECTED", "");
            else if (!apclient_say(_line))
                ap_console_add("AP MESSAGE FAILED TO SEND", "");
        }
    }
}
