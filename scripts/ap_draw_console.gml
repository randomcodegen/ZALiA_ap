/// ap_draw_console()
{
    if (!global.ap_console_open) exit;

    var _font = global.dl_game_font[|global.game_font_idx];
    var _charW = sprite_get_width(_font);
    var _lineH = sprite_get_height(_font) + 2;
    var _xl = viewXL() + 4;
    var _yt = viewYT() + 4;
    var _w = viewW() - 8;
    var _h = viewH() - 8;
    var _cols = floor((_w - 8) / _charW);
    if (_cols < 4) exit;

    draw_sprite_(spr_1x1_WHT, 0, _xl, _yt, -1, _w, _h, c_black, 0.92);
    var _status = "OFFLINE";
    if (global.AP_connected) _status = "ONLINE";
    draw_text_(_xl + 4, _yt + 4, "AP CONSOLE - " + _status, _font, -1, c_white);

    var _input = keyboard_string;
    while (string_length(_input) > 0 && string_char_at(_input, 1) == " ")
        _input = string_delete(_input, 1, 1);
    var _space = string_pos(" ", _input);
    if (_space > 0
    &&  string_upper(string_copy(_input, 1, _space - 1)) == "/PASSWORD")
        _input = string_copy(_input, 1, _space) + string_repeat("*", string_length(_input) - _space);
    if (string_length(_input) > _cols - 3)
        _input = string_copy(_input, string_length(_input) - (_cols - 3) + 1, _cols - 3);
    var _inputY = _yt + _h - (_lineH * 2) - 3;
    draw_text_(_xl + 4, _inputY, ": " + _input + "_", _font, -1, c_white);

    var _help = "TAB COMPLETE  ENTER SEND  F1 CLOSE";
    if (global.ap_console_suggestion != "")
        _help = "TAB: " + global.ap_console_suggestion;
    if (string_length(_help) > _cols)
        _help = string_copy(_help, string_length(_help) - _cols + 1, _cols);
    draw_text_(_xl + 4, _inputY + _lineH, _help, _font, -1, c_white);

    var _y = _inputY - _lineH;
    var _i, _part, _parts, _msg, _colors, _line, _lineColors;
    var _start, _end, _code;
    var _visible = max(1, floor((_y - (_yt + _lineH * 2)) / _lineH) + 1);
    var _total = 0;
    for (_i = 0; _i < ds_list_size(global.ap_console_log); _i++)
        _total += max(1, ceil(string_length(global.ap_console_log[|_i]) / _cols));
    global.ap_console_scroll = clamp(global.ap_console_scroll, 0, max(0, _total - _visible));
    var _skip = global.ap_console_scroll;
    for (_i = ds_list_size(global.ap_console_log) - 1; _i >= 0 && _y >= _yt + _lineH * 2; _i--)
    {
        _msg = global.ap_console_log[|_i];
        _colors = global.ap_console_colors[|_i];
        _parts = max(1, ceil(string_length(_msg) / _cols));
        if (_skip >= _parts)
        {
            _skip -= _parts;
            continue;
        }
        for (_part = _parts - 1 - _skip; _part >= 0 && _y >= _yt + _lineH * 2; _part--)
        {
            _line = string_copy(_msg, _part * _cols + 1, _cols);
            _lineColors = string_copy(_colors, _part * _cols * 8 + 1, string_length(_line) * 8);
            if (_lineColors == "") draw_text_(_xl + 4, _y, _line, _font, -1, c_white);
            else
            {
                _start = 1;
                while (_start <= string_length(_line))
                {
                    _code = string_copy(_lineColors, (_start - 1) * 8 + 1, 8);
                    _end = _start + 1;
                    while (_end <= string_length(_line)
                    && string_copy(_lineColors, (_end - 1) * 8 + 1, 8) == _code)
                        _end++;
                    draw_text_(_xl + 4 + (_start - 1) * _charW, _y,
                        string_copy(_line, _start, _end - _start), _font, -1, real(_code));
                    _start = _end;
                }
            }
            _y -= _lineH;
        }
        _skip = 0;
    }
}
