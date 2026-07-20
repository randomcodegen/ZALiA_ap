/// ap_socket_error(error)
{
    show_debug_message("AP: Socket error: " + string(argument0));
    global.AP_last_error = argument0;
    global.AP_error_time = 180; // ~3 seconds at 60fps before exiting
}
