/// draw_rando_hints()


var _i,_j, _val, _num,_num_, _count;
var _text, _type;
var _item, _item_found, _location_found, _hint_location;
var _pi, _color;


var _FOUND_NUMS = val(g.dm_RandoHintsRecorder[?STR_Found+STR_Hint+STR_Num], "");


_pi = global.PI_GUI2;
var _PI_FOUND1 = add_pi_permut(_pi, "RBWGMKYC", "draw_rando_hints() dark text 1");
var _PI_FOUND2 = _pi;


var _FOUND_COUNT = string_length(_FOUND_NUMS)>>1;

// Boulder Circle push-order line. Each town's wise
var _BLD_DK    = STR_Boulder+STR_Circle+STR_Order;
var _BLD_COUNT = val(g.dm_RandoHintsRecorder[?_BLD_DK+STR_Count], 0);
var _SHOW_BLD  = _BLD_COUNT>0;

var _HEADER_TEXT = "--- "+"HINTS"+" ---";
//var _HEADER_TEXT = "HINTS";

var _CLMS=g.RandoHintsRecorder_W>>3;
var _XL0 = get_menu_x() - ($01<<3) - g.RandoHintsRecorder_W;
    _XL0 = max(_XL0, viewXL() + ($01<<3));
    _XL0 = (_XL0>>3)<<3;
//var _XL0 = viewXL() + ($06<<3);
var _XL1 = _XL0+($01<<3)+2;
var _xl  = _XL0;

var _YT0 = viewYT() + g.PAUSE_MENU.Y_BASE;
//var _YT0 = viewYT() + ($06<<3); // window yt
var _YT1 = _YT0+($01<<3);       // header yt
var _YT2 = _YT1+$8+3;           // hints yt
var _yt  = _YT0;

var _DIST1 = g.RandoHintsRecorder_Font_CHAR_SIZE+2;

// Characters that fit on one line inside the
var _CPL = (g.RandoHintsRecorder_W - ($01<<3) - 2 - ($01<<3)) div g.RandoHintsRecorder_Font_CHAR_SIZE;
if (_CPL < 8) _CPL = 8;

// Pass 1: word-wrap every found hint into
var _LN = 0;              // total wrapped display lines across all hints
var _LT, _LC, _LI, _LIC; // per line: text, base color, item
var _wi, _wlen, _wch, _word, _cur, _dlg, _itm, _bc, _ic;
for (_i = 0; _i < _FOUND_COUNT; _i++)
{
    _num_ = string_copy(_FOUND_NUMS, (_i<<1)+1, 2);
    _item = g.dm_RandoHintsRecorder[?STR_Hint+_num_+STR_Item];
    if (is_undefined(_item)) continue;
    _item_found = val(g.dm_RandoHintsRecorder[?STR_Hint+_num_+STR_Item+STR_Found]);
    _location_found = _item_found;

    // In AP play, checked-location state is more precise than whether this
    // client happens to own the hinted item (especially for cross-world items).
    if (variable_global_exists("ap_checked_ids")
    && !is_undefined(global.ap_checked_ids)
    &&  ds_exists(global.ap_checked_ids, ds_type_list))
    {
        _hint_location = val(f.dm_rando[?STR_Rando+STR_Hint+_num_+STR_Location], 0);
        if (_hint_location > 0
        &&  ds_list_find_index(global.ap_checked_ids, _hint_location) != -1)
        {
            _location_found = true;
        }
    }
    if (_location_found) continue;

    // The recorder stores the full flattened hint
    _dlg = g.dm_RandoHintsRecorder[?STR_Hint+_num_+STR_Dialogue];
    if (is_undefined(_dlg) || !is_string(_dlg) || _dlg == "")
        _dlg = val(g.dm_RandoHintsRecorder[?STR_Hint+_num_+STR_Text+"01"], "")
             + string_letters(_item)
             + val(g.dm_RandoHintsRecorder[?STR_Hint+_num_+STR_Text+"02"], "");

    _itm = string_letters(_item);
    _bc = p.C_WHT1;
    _ic = p.C_GRN2;

    // Word-wrap _dlg to <= _CPL chars/line
    _cur  = "";
    _word = "";
    _wlen = string_length(_dlg);
    for (_wi = 1; _wi <= _wlen + 1; _wi++)
    {
        if (_wi <= _wlen) _wch = string_char_at(_dlg, _wi);
        else              _wch = " "; // sentinel flushes the final word
        if (_wch != " ") { _word += _wch; continue; }
        if (_word == "") continue;

        while (string_length(_word) > _CPL)
        {
            if (_cur != "")
            {
                _LT[_LN]=_cur; _LC[_LN]=_bc; _LI[_LN]=_itm; _LIC[_LN]=_ic; _LN++;
                _cur = "";
            }
            _LT[_LN]=string_copy(_word,1,_CPL); _LC[_LN]=_bc; _LI[_LN]=_itm; _LIC[_LN]=_ic; _LN++;
            _word = string_copy(_word, _CPL+1, string_length(_word)-_CPL);
        }

        if (_cur == "") _cur = _word;
        else if (string_length(_cur)+1+string_length(_word) <= _CPL) _cur += " " + _word;
        else { _LT[_LN]=_cur; _LC[_LN]=_bc; _LI[_LN]=_itm; _LIC[_LN]=_ic; _LN++; _cur = _word; }
        _word = "";
    }
    if (_cur != "") { _LT[_LN]=_cur; _LC[_LN]=_bc; _LI[_LN]=_itm; _LIC[_LN]=_ic; _LN++; }
}

_count = max(_LN + _SHOW_BLD, 1);
var _H  = $8<<1; // borders
    _H += $8;    // header text
    _H += $2<<1; // top & bottom padding
    _H += _count*g.RandoHintsRecorder_Font_CHAR_SIZE;
    _H +=(_count-1)*2; // leading
    _H  = ((_H div 8)<<3) + (sign(_H mod 8)<<3); // round up to 8

// Keep the recorder inside the viewport. Only the visible wrapped lines are
// drawn; PauseMenu_update_2a changes hintScroll with the normal up/down input.
var _H_MAX = ((viewYB()-_YT0) div 8)<<3;
_H = min(_H, _H_MAX);

var _VISIBLE_LINES = ((_H - (_YT2-_YT0) - $8 - 2 - g.RandoHintsRecorder_Font_CHAR_SIZE) div _DIST1) + 1;
_VISIBLE_LINES = max(_VISIBLE_LINES, 1);
var _CONTENT_LINES = _LN + _SHOW_BLD;
var _SCROLL = 0;
if (instance_exists(g.PAUSE_MENU))
{
    g.PAUSE_MENU.hintScrollMax = max(_CONTENT_LINES-_VISIBLE_LINES, 0);
    g.PAUSE_MENU.hintScroll = clamp(g.PAUSE_MENU.hintScroll, 0, g.PAUSE_MENU.hintScrollMax);
    _SCROLL = g.PAUSE_MENU.hintScroll;
}
//
var _ROWS = _H>>3;


draw_sprite_(spr_1x1_WHT,0, _XL0,_YT0, -1, g.RandoHintsRecorder_W,_H, c_black);

_count  = string_length(_HEADER_TEXT);
_count += _count&$1;
for(_i=0;_i<_ROWS;_i++)
{
    for(_j=0;_j<_CLMS;_j++)
    {
            _type  =  !_i || _i==_ROWS-1;
            _type |= (!_j || _j==_CLMS-1) <<1;
        if (_type)
        {
            /*
            if (_i 
            ||  _j<(_CLMS>>1)-(_count>>1) 
            ||  _j>(_CLMS>>1)+(_count>>1) )
            */
            _xl  = _XL0 + (_j<<3);
            _yt  = _YT0 + (_i<<3);
            // tsrc: $20: horizontal, $21: vertical, $22: corner
            draw_background_part_ext_(global.PI_GUI1,ts_Menu01, (_type-1)<<3,$2<<3, 8,8, _xl,_yt, 1,1);
        }
    }
}


_xl  = _XL0 + ((_CLMS<<3)>>1);
_xl -= (string_length(_HEADER_TEXT)<<3)>>1;
_yt  = _YT1;
draw_text_(_xl,_yt, _HEADER_TEXT, global.dl_game_font[|global.game_font_idx], global.PI_GUI1);



if(!_LN && !_SHOW_BLD)
{
    _xl  = _XL1;
    _yt  = _YT2;
    if (_FOUND_COUNT) _text = "NO UNFOUND HINTS!";
    else              _text = "NO HINTS FOUND YET!";
    draw_text_(_xl,_yt, _text, g.RandoHintsRecorder_Font_SPRITE, global.PI_GUI1);
    exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}

//C_WHT1 C_BLU2 C_RED3
_xl  = _XL1;
_yt  = _YT2;

// Boulder push order: "BOULDERS: N NE ? W". It occupies the first
// scrollable line, ahead of the recorded hints.
var _DRAWN_LINES = 0;
if (_SHOW_BLD && _SCROLL==0 && _DRAWN_LINES<_VISIBLE_LINES)
{
    _xl = _XL1;
    draw_text_(_xl,_yt, "BOULDERS:", g.RandoHintsRecorder_Font_SPRITE, -1, p.C_WHT1);
    _xl += string_length("BOULDERS:")*g.RandoHintsRecorder_Font_CHAR_SIZE;
    for(_j=1; _j<=_BLD_COUNT; _j++)
    {
        _xl += g.RandoHintsRecorder_Font_CHAR_SIZE; // leading space
        _val = g.dm_RandoHintsRecorder[?_BLD_DK+hex_str(_j)];
        if (is_undefined(_val)) { _val="?"; _color=p.C_GRY2; }
        else                          _color=p.C_GRN2;
        draw_text_(_xl,_yt, _val, g.RandoHintsRecorder_Font_SPRITE, -1, _color);
        _xl += string_length(_val)*g.RandoHintsRecorder_Font_CHAR_SIZE;
    }
    _yt += _DIST1;
    _DRAWN_LINES++;
}

// Draw the pre-wrapped hint lines (Pass 1
var _line, _itmtok, _p, _pre, _post;
var _FIRST_HINT_LINE = max(_SCROLL-_SHOW_BLD, 0);
for(_i=_FIRST_HINT_LINE; _i<_LN && _DRAWN_LINES<_VISIBLE_LINES; _i++)
{
    _xl     = _XL1;
    _line   = _LT[_i];
    _itmtok = _LI[_i];
    _color  = _LC[_i];

    _p = 0;
    if (_itmtok != "") _p = string_pos(_itmtok, _line);
    if (_p > 0)
    {
        if (_p > 1)
        {
            _pre = string_copy(_line, 1, _p-1);
            draw_text_(_xl,_yt, _pre, g.RandoHintsRecorder_Font_SPRITE, -1, _color);
            _xl += string_length(_pre)*g.RandoHintsRecorder_Font_CHAR_SIZE;
        }
        draw_text_(_xl,_yt, _itmtok, g.RandoHintsRecorder_Font_SPRITE, -1, _LIC[_i]);
        _xl += string_length(_itmtok)*g.RandoHintsRecorder_Font_CHAR_SIZE;
        _post = strR(_line, _p + string_length(_itmtok));
        if (_post != "")
            draw_text_(_xl,_yt, _post, g.RandoHintsRecorder_Font_SPRITE, -1, _color);
    }
    else
    {
        draw_text_(_xl,_yt, _line, g.RandoHintsRecorder_Font_SPRITE, -1, _color);
    }

    _yt += _DIST1;
    _DRAWN_LINES++;
}




