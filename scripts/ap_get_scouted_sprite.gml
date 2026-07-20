/// ap_get_scouted_sprite(ap_item_name)
{
    var _gml_name = ap_name_to_gml(argument0);
    if (_gml_name == "") return -1;
    var _spr = val(g.dm_ITEM[?_gml_name+STR_Sprite], -1);
    if (_spr == -1 && string_pos(STR_KEY, _gml_name) == 1)
    {
        // Palace-specific key name (e.g. "_KEY04")
        _spr = val(g.dm_ITEM[?STR_KEY+STR_Sprite], -1);
    }
    return _spr;
}
