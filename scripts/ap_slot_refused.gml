/// ap_slot_refused(error_count)
{
    if (global.ap_console_failure_shown) exit;
    show_debug_message("AP: Slot connection refused");
    global.AP_connected = false;
    global.ap_connect_started = 0;
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

    var _reason = "AP ERROR: SLOT REFUSED";
    var _i;
    for (_i = 0; _i < min(16, argument0); _i++)
    {
        if (global.arg_errors[_i] != "")
            _reason += ": " + global.arg_errors[_i];
        global.arg_errors[_i] = "";
    }
    global.AP_last_error = _reason;
    apclient_disconnect();
    ap_console_add(_reason + ". USE /CONNECT TO RETRY.", "");
}
