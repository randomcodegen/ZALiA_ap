/// ap_console_add(text, colors)
{
    ds_list_add(global.ap_console_log, argument0);
    ds_list_add(global.ap_console_colors, argument1);
    while (ds_list_size(global.ap_console_log) > 50)
    {
        ds_list_delete(global.ap_console_log, 0);
        ds_list_delete(global.ap_console_colors, 0);
    }
}
