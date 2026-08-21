/// ap_socket_disconnected()
{
    show_debug_message("AP: Socket disconnected");
    global.AP_connected = false;
    // Allow reconnection attempt
    global.AP_connect_attempted = false;
    global.AP_slot_connect_attempted = false;
}
