/// ap_grant_pbag(received_index)
{
    // The AP item index identifies this bag across save files and reconnects.
    var _ver = 1;
    var _def_count = 0;
    if (variable_instance_exists(f, "dm_PBags_DEFAULT") && ds_exists(f.dm_PBags_DEFAULT, ds_type_map))
        _def_count = val(f.dm_PBags_DEFAULT[?STR_Count]);

    var _count = _def_count;
    if (_count <= 0) _count = 10;
    var _pick;
    if (argument0 >= 0)
    {
        var _oldSeed = random_get_seed();
        random_set_seed(global.ap_seed + argument0);
        _pick = irandom_range(1, _count);
        random_set_seed(_oldSeed);
    }
    else _pick = irandom_range(1, _count);

    if (_def_count > 0)
    {
        _ver = val(f.dm_PBags_DEFAULT[?hex_str(_pick) + STR_Version], 1);
    }
    else
    {
        _ver = _pick; // fallback: pick random tier
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
