/// ap_socket_connected()
{
    show_debug_message("AP: Socket connected");
    global.AP_last_error = "";
    global.AP_error_time = 0; // A successful fallback cancels the earlier TLS error.
}
