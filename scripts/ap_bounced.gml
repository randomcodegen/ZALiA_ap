/// ap_bounced(bounce)
{
    var _bounce = argument0;
    show_debug_message("AP: Bounce received: " + _bounce);

    if (!global.ap_deathlink_enabled) exit;

    if (string_pos("DeathLink", _bounce) == 0) exit;

    var _dm = json_decode(_bounce);
    if (_dm == -1) exit;

    var _source = ds_map_find_value(_dm, "source");
    if (is_undefined(_source)) _source = "Unknown";
    var _cause = ds_map_find_value(_dm, "cause");
    if (is_undefined(_cause)) _cause = "Unknown cause";

    show_debug_message("AP: DeathLink from " + string(_source) + ": " + string(_cause));

    if ((g.room_type == "A" || g.room_type == "C")
    && variable_global_exists("pc") && global.pc != noone)
    {
        global.pc.is_dead = 1;
        show_debug_message("AP: DeathLink triggered player death");
    }

    ds_map_destroy(_dm);
}
