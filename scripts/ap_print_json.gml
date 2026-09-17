/// ap_print_json(message)
{
    var _text = apclient_render_json(argument0, global.AP_RENDER_FORMAT_TEXT);
    show_debug_message("AP: " + _text);

    // Resolve each server text node with the DLL, retaining its semantic color.
    var _message = json_decode(argument0);
    if (_message == -1) exit;
    var _nodes = _message[? "data"];
    if (!is_real(_nodes)) { ds_map_destroy(_message); exit; }
    if (!ds_exists(_nodes, ds_type_list)) { ds_map_destroy(_message); exit; }
    var _clean = "";
    var _colors = "";
    var _ni, _sk, _sc;
    for (_ni = 0; _ni < ds_list_size(_nodes); _ni++)
    {
        var _node = _nodes[|_ni];
        if (!is_real(_node)) continue;
        if (!ds_exists(_node, ds_type_map)) continue;
        if (!is_string(_node[? "text"])) continue;
        _text = string_upper(apclient_render_json('{"data":[' + json_encode(_node) + ']}', global.AP_RENDER_FORMAT_TEXT));
        // The sprite font has parentheses but no square brackets.
        _text = string_replace_all(string_replace_all(_text, "[", "("), "]", ")");
        for (_sk = 1; _sk <= string_length(_text); _sk++)
        {
            _sc = string_char_at(_text, _sk);
            if (string_pos(_sc, FONT_LAYOUT) > 0) _clean += _sc;
            else                                  _clean += " ";
        }
        // Fixed-width decimal colors stay aligned with characters when wrapping.
        _colors += string_repeat(string_format(ap_message_color(_node), 8, 0), string_length(_text));
    }
    ds_map_destroy(_message);
    _text = _clean;

    ds_list_add(global.ap_message_buffer, _text);
    ds_list_add(global.ap_message_colors, _colors);
    ds_list_add(global.ap_message_timers, 360); // 6 seconds at 60fps

    // Keep last 5 messages
    while (ds_list_size(global.ap_message_buffer) > 5)
    {
        ds_list_delete(global.ap_message_buffer, 0);
        ds_list_delete(global.ap_message_colors, 0);
        ds_list_delete(global.ap_message_timers, 0);
    }
}
