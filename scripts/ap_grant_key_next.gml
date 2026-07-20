/// ap_grant_key_next(palace_num)
{
    var _palace = argument0;
    var _count = val(g.dm_spawn[?STR_Dungeon+hex_str(_palace)+STR_Key+STR_Count]);
    var _i, _key_id;

    for (_i = 1; _i <= _count; _i++)
    {
        _key_id = STR_KEY + hex_str(_palace) + hex_str(_i);
        if (!val(f.dm_keys[?_key_id + STR_Acquired]))
        {
            f.dm_keys[?_key_id + STR_Acquired] = true;
            f.key_count = get_key_count(_palace);
            return true;
        }
    }

    return false;
}
