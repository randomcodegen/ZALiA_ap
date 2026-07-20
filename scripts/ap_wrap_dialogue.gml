/// ap_wrap_dialogue(text)
{
    var _text = argument0;
    if (is_undefined(_text) || !is_string(_text) || _text == "") return "";

    // CHAR_PER_LINE_MAX = GUI_WIN_CLMS1 - 4 (=10)
    var _cpl = 10;
    if (variable_instance_exists(g, "GUI_WIN_CLMS1")) _cpl = g.GUI_WIN_CLMS1 - 4;
    if (_cpl < 4) _cpl = 10;
    var _maxl = 4;
    var _brk = "<";

    // Existing line breaks become spaces
    _text = string_replace_all(_text, _brk, " ");
    _text = string_replace_all(_text, ">", " ");

    var _out = "";      // finished lines joined by _brk
    var _lines = 0;     // count of finished lines in _out
    var _cur = "";      // line currently being built
    var _word = "";
    var _i, _ch;
    var _len = string_length(_text);

    for (_i = 1; _i <= _len + 1; _i++)
    {
        if (_i <= _len) _ch = string_char_at(_text, _i);
        else            _ch = " "; // sentinel flushes the final word

        if (_ch != " ")
        {
            _word += _ch;
            continue;
        }
        if (_word == "") continue;

        // Hard-split words that can't fit on a single
        while (string_length(_word) > _cpl)
        {
            if (_cur != "")
            {
                if (_lines > 0) _out += _brk;
                _out += _cur;
                _lines++;
                _cur = "";
                if (_lines >= _maxl) return _out;
            }
            if (_lines > 0) _out += _brk;
            _out += string_copy(_word, 1, _cpl);
            _lines++;
            _word = string_copy(_word, _cpl + 1, string_length(_word) - _cpl);
            if (_lines >= _maxl) return _out;
        }

        if (_cur == "")
        {
            _cur = _word;
        }
        else if (string_length(_cur) + 1 + string_length(_word) <= _cpl)
        {
            _cur += " " + _word;
        }
        else
        {
            if (_lines > 0) _out += _brk;
            _out += _cur;
            _lines++;
            _cur = _word;
            if (_lines >= _maxl) return _out;
        }

        _word = "";
    }

    if (_cur != "" && _lines < _maxl)
    {
        if (_lines > 0) _out += _brk;
        _out += _cur;
    }

    return _out;
}
