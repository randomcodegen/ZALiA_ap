/// ap_bounced(bounce)
{
    if (!global.AP_connected || !global.ap_deathlink_enabled) exit;

    var _dm = json_decode(argument0);
    if (_dm == -1) exit;
    var _tags = ds_map_find_value(_dm, "tags");
    var _data = ds_map_find_value(_dm, "data");
    if (is_real(_tags) && ds_exists(_tags, ds_type_list)
    &&  ds_list_find_index(_tags, "DeathLink") != -1
    &&  is_real(_data) && ds_exists(_data, ds_type_map))
    {
        var _source = ds_map_find_value(_data, "source");
        var _time = ds_map_find_value(_data, "time");
        if (!is_undefined(_source) && !is_undefined(_time)
        &&  string(_source) != global.ap_slot
        &&  _time != global.ap_deathlink_last_time)
        {
            global.ap_deathlink_last_time = _time;
            var _cause = ds_map_find_value(_data, "cause");
            if (is_undefined(_cause)) _cause = "";
            show_debug_message("AP: DeathLink from " + string(_source) + ": " + string(_cause));

            if (global.ap_save_loaded && g.room_type == "A"
            &&  global.pc != noone && instance_exists(global.pc)
            &&  !global.pc.is_dead)
            {
                global.ap_deathlink_remote_pending = true;
                global.pc.is_dead = true;
                global.pc.stun_timer = 0;
                PC_update_death();
            }
            else if (global.ap_save_loaded && g.room_type == "C")
            {
                global.BackgroundColor_at_death = background_colour;
                audio_stop_sound(Audio.mus_rm_inst);
                aud_play_sound(get_audio_theme_track(STR_PC+STR_Death));
                room_goto_(rmB_Death);
            }
        }
    }
    ds_map_destroy(_dm);
}
