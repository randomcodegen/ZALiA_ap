/// ap_slot_refused()
{
    show_debug_message("AP: Slot connection refused");
    global.AP_connected = false;
    global.AP_connect_attempted = false;
    
    var _reason = "";
    if (variable_global_exists("arg_errors") && global.arg_errors[0] != "")
    {
        _reason = ": " + global.arg_errors[0];
    }
    show_message("Slot connection refused" + _reason + "#Check your slot name and password.#The game will now close.");
    game_end();
}
