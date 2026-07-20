/// ap_draw_messages()

if (!variable_global_exists("ap_message_timers")) exit;

var _count = ds_list_size(global.ap_message_buffer);
if (_count == 0) exit;

var _FONT_SPR  = global.dl_game_font[|global.game_font_idx];
var _CHAR_W    = sprite_get_width(_FONT_SPR);
var _CHAR_H    = sprite_get_height(_FONT_SPR);
var _LINE_H    = _CHAR_H + 2;
var _PAD_X     = 3;
var _PAD_Y     = 1;
var _XL        = viewXL() + 4;
var _YB        = viewYT() + viewH() - 4;

// Characters that fit between left anchor and right
var _MAX_CHARS = (viewW() - (_XL - viewXL()) - 8) div _CHAR_W;
if (_MAX_CHARS < 1) _MAX_CHARS = 1;

// Build a flat list of visual lines
var _dl_texts  = ds_list_create();
var _dl_timers = ds_list_create();

var _i;
var _bp, _line, _ns;
for (_i = 0; _i < _count; _i++)
{
    var _msg   = global.ap_message_buffer[|_i];
    var _timer = global.ap_message_timers[|_i];

    var _rem = _msg;
    while (string_length(_rem) > _MAX_CHARS)
    {
        // Search backward from _MAX_CHARS for a space
        _bp = _MAX_CHARS;
        while (_bp > 1 && string_char_at(_rem, _bp) != " ")
            _bp -= 1;

        if (_bp > 1) // found a space — break before it
        {
            _line = string_copy(_rem, 1, _bp - 1);
            _ns   = _bp + 1; // skip the space
        }
        else // no space in range
        {
            _line = string_copy(_rem, 1, _MAX_CHARS);
            _ns   = _MAX_CHARS + 1;
        }

        ds_list_add(_dl_texts,  _line);
        ds_list_add(_dl_timers, _timer);
        _rem = string_delete(_rem, 1, _ns - 1);
    }
    // Remainder (or full message if it fits)
    if (string_length(_rem) > 0)
    {
        ds_list_add(_dl_texts,  _rem);
        ds_list_add(_dl_timers, _timer);
    }
}

var _line_count = ds_list_size(_dl_texts);

// Draw bottom-up: slot 0 = bottom-most
for (_i = 0; _i < _line_count; _i++)
{
    var _text  = _dl_texts[|_i];
    var _timer = _dl_timers[|_i];

    var _alpha;
    if (_timer < 60) _alpha = _timer / 60;
    else             _alpha = 1;

    var _slot  = (_line_count - 1) - _i;
    var _y     = _YB - (_slot + 1) * _LINE_H - _PAD_Y;
    var _txt_w = string_length(_text) * _CHAR_W;

    // Black background rectangle
    draw_sprite_(spr_1x1_WHT, 0,
        _XL - _PAD_X, _y - _PAD_Y,
        -1,
        _txt_w + _PAD_X * 2, _CHAR_H + _PAD_Y * 2,
        c_black,
        _alpha * 0.65);

    // Text fades by darkening toward black
    var _lum = floor(255 * _alpha);
    draw_text_(_XL, _y, _text, _FONT_SPR, -1, make_colour_rgb(_lum, _lum, _lum));
}

ds_list_destroy(_dl_texts);
ds_list_destroy(_dl_timers);
