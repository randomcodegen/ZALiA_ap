/// ap_print_json(message)
{
    var _text = apclient_render_json(argument0, global.AP_RENDER_FORMAT_TEXT);
    show_debug_message("AP: " + _text);

    // Sanitize for the sprite font used
    _text = string_upper(_text);
    var _clean = "";
    var _sn = string_length(_text);
    var _sk, _sc;
    for (_sk = 1; _sk <= _sn; _sk++)
    {
        _sc = string_char_at(_text, _sk);
        if (string_pos(_sc, FONT_LAYOUT) > 0) _clean += _sc;
        else                                  _clean += " ";
    }
    _text = _clean;

    ds_list_add(global.ap_message_buffer, _text);
    ds_list_add(global.ap_message_timers, 360); // 6 seconds at 60fps

    // Keep last 5 messages
    while (ds_list_size(global.ap_message_buffer) > 5)
    {
        ds_list_delete(global.ap_message_buffer, 0);
        ds_list_delete(global.ap_message_timers, 0);
    }
}
