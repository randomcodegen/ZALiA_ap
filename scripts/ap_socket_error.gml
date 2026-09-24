/// ap_socket_error(error)
{
    show_debug_message("AP: Socket error: " + string(argument0));
    global.AP_last_error = argument0;
}
