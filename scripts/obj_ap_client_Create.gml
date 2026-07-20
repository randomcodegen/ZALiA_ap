/// obj_ap_client_Create()
{
    // AP client state
    global.AP_connected = false;
    global.AP_connected_slot = "";
    global.ap_server = "localhost:38281";
    global.ap_slot = "Player1";
    global.ap_password = "";
    global.AP_connect_attempted = false;
    global.AP_last_error = "";
    global.AP_error_time = 0;
    // Spell-sequence puzzle spells sent by the
    global.ap_spell_sequences = undefined;

    // Load conn details from config file
    var _cfg_dir = environment_get_variable("LOCALAPPDATA");
    if (_cfg_dir == "") _cfg_dir = working_directory;
    var _cfg_path = _cfg_dir + "\ZALiA\ap_config.ini";
    ini_open(_cfg_path);
    if (ini_key_exists("Connection", "server"))
    {
        global.ap_server   = ini_read_string("Connection", "server",   global.ap_server);
        global.ap_slot     = ini_read_string("Connection", "slot",     global.ap_slot);
        global.ap_password = ini_read_string("Connection", "password", global.ap_password);
        ini_close();
    }
    else
    {
        ini_write_string("Connection", "server",   global.ap_server);
        ini_write_string("Connection", "slot",     global.ap_slot);
        ini_write_string("Connection", "password", global.ap_password);
        ini_close();
        show_debug_message("Created ap_config.ini — edit " + _cfg_path + " and restart");
    }
    // Strip ws:// prefix if user included it (DLL
    if (string_pos("://", global.ap_server) > 0)
    {
        var _proto_end = string_pos("://", global.ap_server) + 3;
        global.ap_server = string_copy(global.ap_server, _proto_end, string_length(global.ap_server) - _proto_end + 1);
    }
    show_debug_message("AP config — server: " + global.ap_server + ", slot: " + global.ap_slot);

    // Initialize global arrays for event arguments
    global.arg_ids[0] = 0;
    global.arg_names[0] = "";
    global.arg_items[0] = 0;
    global.arg_flags[0] = 0;
    global.arg_players[0] = 0;
    global.arg_locations[0] = 0;
    global.arg_errors[0] = "";

    // Set up constants
    ap_init();

    // Init the DLL (defined in extension)
    apclient_init(1);

    show_debug_message("AP Client initialised");
}
