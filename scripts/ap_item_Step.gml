/// ap_item_Step()
{
    // Native collision state + body hitbox update
    GO_update_cs();
    GOB_update_2();

    // Stab-only pickup via the PC's secondary sword
    var _pc = global.pc;
    if (!is_undefined(_pc) && _pc != noone
    &&  _pc.SwordHB2_collidable
    &&  rectInRect(bbox_left, bbox_top, (bbox_right - bbox_left) + 1, (bbox_bottom - bbox_top) + 1,
                   _pc.SwordHB2_xl, _pc.SwordHB2_yt, _pc.SwordHB2_w, _pc.SwordHB2_h) )
    {
        aud_play_sound(get_audio_theme_track(dk_StabItem));

        if (global.AP_connected && !is_undefined(ap_loc_id))
        {
            apclient_location_checks("[" + string(ap_loc_id) + "]");
            show_debug_message("AP: Cross-world item checked, ap_loc_id=" + string(ap_loc_id));

            // Track for reconnect re-send (dedup)
            if (!variable_global_exists("ap_checked_ids"))
                global.ap_checked_ids = ds_list_create();
            if (ds_list_find_index(global.ap_checked_ids, ap_loc_id) == -1)
                ds_list_add(global.ap_checked_ids, ap_loc_id);
        }

        instance_destroy(id);
        exit; // !!!!! picked up
    }

    // Native gravity + landing (falls onto solid ground)
    Item_update_vertical();
}
