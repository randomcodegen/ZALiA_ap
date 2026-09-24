/// ap_console_add(text, colors)
{
    if (global.ap_console_scroll > 0)
    {
        var _font = global.dl_game_font[|global.game_font_idx];
        var _cols = max(4, floor((viewW() - 16) / sprite_get_width(_font)));
        global.ap_console_scroll += max(1, ceil(string_length(argument0) / _cols));
    }
    ds_list_add(global.ap_console_log, argument0);
    ds_list_add(global.ap_console_colors, argument1);
    while (ds_list_size(global.ap_console_log) > 2048)
    {
        ds_list_delete(global.ap_console_log, 0);
        ds_list_delete(global.ap_console_colors, 0);
    }
}
