/// ap_send_deathlink()
{
    if (!global.AP_connected) exit;
    if (!global.ap_deathlink_enabled) exit;

    var _cause = "Zelda died";
    if (global.ap_local_player > 0)
    {
        var _alias = apclient_get_player_alias(global.ap_local_player);
        if (_alias != "")
            _cause = _alias + " died";
    }
    apclient_death_link(_cause);
    show_debug_message("AP: DeathLink sent: " + _cause);
}
