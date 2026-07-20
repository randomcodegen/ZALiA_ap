/// ap_grant_pbag()
{
    // Pick a version the way the in-game P-Bags are received
    var _ver = 1;
    var _def_count = 0;
    if (variable_instance_exists(f, "dm_PBags_DEFAULT") && ds_exists(f.dm_PBags_DEFAULT, ds_type_map))
        _def_count = val(f.dm_PBags_DEFAULT[?STR_Count]);

    if (_def_count > 0)
    {
        var _pick = irandom_range(1, _def_count);
        _ver = val(f.dm_PBags_DEFAULT[?hex_str(_pick) + STR_Version], 1);
    }
    else
    {
        _ver = irandom_range(1, 10); // defensive fallback: any tier, still varied
    }

    // Version -> XP via the exact same path
    var _objver = object_get_name(ItmF0) + hex_str(_ver);
    var _xp_idx = val(g.dm_go_prop[?_objver + STR_XP]);
    var _xp     = g.dl_XP[| _xp_idx];
    show_debug_message("AP: P-Bag +" + string(_xp) + " XP (ver " + string(_ver) + ", idx $" + hex_str(_xp_idx) + ")");

    // Bank the XP.
    if (!variable_global_exists("ap_deferred_xp")) global.ap_deferred_xp = 0;
    global.ap_deferred_xp += _xp;
    show_debug_message("AP: Banked " + string(_xp) + " P-Bag XP (deferred total " + string(global.ap_deferred_xp) + ")");

    return true;
}
