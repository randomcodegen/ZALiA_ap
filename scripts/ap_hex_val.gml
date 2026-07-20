/// ap_hex_val(hex_string)
{
    var _hex = argument0;
    var _len = string_length(_hex);
    var _val = 0;
    var _i, _c;
    for (_i = 1; _i <= _len; _i++)
    {
        _c = string_char_at(_hex, _i);
        _val = _val << 4;
        if (_c >= "0" && _c <= "9") _val += ord(_c) - 48;
        else if (_c >= "A" && _c <= "F") _val += ord(_c) - 55;
        else if (_c >= "a" && _c <= "f") _val += ord(_c) - 87;
        else return 0;
    }
    return _val;
}
