/// ap_grant_cont_piece(type_str)
{
    var _type = argument0;
    var _cont_max, _pieces_per, _acquired_str;
    var _i, _j, _piece_id, _found;

    if (_type == STR_HEART)
    {
        // Search one container beyond the last completed
        _cont_max = cont_cnt_hp() + 2;
        _pieces_per = f.CONT_PIECE_PER_HP;
        _acquired_str = f.cont_pieces_hp;
    }
    else
    {
        _cont_max = cont_cnt_mp() + 2;
        _pieces_per = f.CONT_PIECE_PER_MP;
        _acquired_str = f.cont_pieces_mp;
    }

    for (_i = 1; _i <= _cont_max; _i++)
    {
        for (_j = 1; _j <= _pieces_per; _j++)
        {
            _piece_id = hex_str(_i) + hex_str(_j);
            _found = false;
            var _k;
            for (_k = 0; _k < string_length(_acquired_str) >> 2; _k++)
            {
                if (string_copy(_acquired_str, (_k << 2) + 1, 4) == _piece_id)
                {
                    _found = true;
                    break;
                }
            }
            if (!_found)
            {
                with (f)
                {
                    if (_type == STR_HEART)
                        cont_pieces_hp += _piece_id;
                    else
                        cont_pieces_mp += _piece_id;
                }
                if (_type == STR_HEART)
                    g.StatRestore_timer_hp = get_stat_max(STR_Heart);
                else
                    g.StatRestore_timer_mp = get_stat_max(STR_Magic);
                return true;
            }
        }
    }

    return false;
}
