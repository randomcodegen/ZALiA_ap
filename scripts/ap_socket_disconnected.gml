/// ap_socket_disconnected()
{
    show_debug_message("AP: Socket disconnected");
    if (global.AP_connected)
        global.ap_connect_started = current_time;
    global.AP_connected = false;
    global.AP_slot_connect_attempted = false;
}
