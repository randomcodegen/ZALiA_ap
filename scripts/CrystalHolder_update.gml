/// CrystalHolder_update()


if(!counter)
//if (counter&$80)
{
    CrystalHolder_udp();
    exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}






// --------------------------------------------------------------------------
// 9AD4: JSR 9B95
if (Flash_timer) // 0767
{   // Flash the midtone color of the crystal holder graphic.
        Flash_timer--;          // 0: blue, 1: white, 2: green, 3: red
    if (Flash_timer) midtone_colorID_cur = dl_COLOR_ID[|Flash_timer&$3];
    else             midtone_colorID_cur = midtone_colorID_DEF;
    change_pal(strReplaceAt(p.pal_rm_new,  midtone_PALDATA_POS, global.PAL_CHAR_PER_COLOR, midtone_colorID_cur));
}




// --------------------------------------------------------------------------
CrystalHolder_udp();




// --------------------------------------------------------------------------
// 9ADE
switch(counter) // 00AF[eIndex]
{   // =====================================================================
    // --------------------------------------------------------------
    case 1:{ // 9AEB
    if (ocs) break; // ####################
    
    
    // 9AF4: JSR E4D9
    GOB_body_collide_pc_body_1a();
    
    if ((cs&CS_BD1)     // colliding w/ PC body
    && !global.pc.ogr ) // PC confirmed to be on ground
    {   // 9B03
        g.pc_lock = PC_LOCK_ALL; // Lock all
        PC_set_behavior(global.pc.behavior_IDLE);
        
        set_xlyt(id, xl,global.pc.yt);
        
        f.crystals |= $1<<(DUNGEON_NUM-1);

        // AP: this palace's crystal is a real location
        if (global.AP_connected
        &&  variable_global_exists("ap_location_name_to_id")
        && !is_undefined(global.ap_location_name_to_id))
        {
            var _crystal_loc_name = "";
            var _boss_item_loc_name = "";
            switch(DUNGEON_NUM)
            {
                case 1:{ _crystal_loc_name = "Parapa Palace: Crystal";         _boss_item_loc_name = "Parapa Palace: Boss Item";         break; }
                case 2:{ _crystal_loc_name = "Midoro Palace: Crystal";         _boss_item_loc_name = "Midoro Palace: Boss Item";         break; }
                case 3:{ _crystal_loc_name = "Island Palace: Crystal";         _boss_item_loc_name = "Island Palace: Boss Item";         break; }
                case 4:{ _crystal_loc_name = "Maze Island Palace: Crystal";    _boss_item_loc_name = "Maze Island Palace: Boss Item";    break; }
                case 5:{ _crystal_loc_name = "Palace on the Sea: Crystal";     _boss_item_loc_name = "Palace on the Sea: Boss Item";     break; }
                case 6:{ _crystal_loc_name = "Three Eye Rock Palace: Crystal"; _boss_item_loc_name = "Three Eye Rock Palace: Boss Item"; break; }
            }
            if (!variable_global_exists("AP_location_map"))
                global.AP_location_map = ds_map_create();

            if (_crystal_loc_name != "")
            {
                var _crystal_ap_id = ds_map_find_value(global.ap_location_name_to_id, _crystal_loc_name);
                if (!is_undefined(_crystal_ap_id))
                {
                    var _crystal_dk = STR_Crystal + hex_str(DUNGEON_NUM);
                    global.AP_location_map[?_crystal_dk] = _crystal_ap_id;
                    global.AP_location_map[?_crystal_dk + "_desc"] = _crystal_loc_name;
                    ap_check_location(_crystal_dk, undefined, g.rm_name, x, y);
                }
            }

            // Boss item — only when the apworld enabled
            var _boss_items_on = false;
            if (variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
            {
                var _bi_opt = ds_map_find_value(global.ap_slot_data, "boss_item_locations");
                _boss_items_on = !is_undefined(_bi_opt) && real(_bi_opt);
            }
            if (_boss_items_on && _boss_item_loc_name != "")
            {
                var _boss_ap_id = ds_map_find_value(global.ap_location_name_to_id, _boss_item_loc_name);
                if (is_undefined(_boss_ap_id)
                &&  variable_global_exists("ap_boss_item_location_ids")
                && !is_undefined(global.ap_boss_item_location_ids))
                    _boss_ap_id = ds_map_find_value(global.ap_boss_item_location_ids, string(DUNGEON_NUM));

                if (!is_undefined(_boss_ap_id))
                {
                    var _boss_dk = STR_Crystal + STR_Item + hex_str(DUNGEON_NUM);
                    global.AP_location_map[?_boss_dk] = _boss_ap_id;
                    global.AP_location_map[?_boss_dk + "_desc"] = _boss_item_loc_name;
                    ap_check_location(_boss_dk, undefined, g.rm_name, x, y);
                }
            }
        }

        aud_play_sound(get_audio_theme_track(STR_Sword+STR_Beam));
        audio_group_stop_all(audiogroup_mus); // stop music?
        // stop mus_rm_body from playing until hp/mp restore is done
        Audio.can_play_mus_rm_body = false;
        Audio.can_play_boss_music  = false;
        
        counter++;
    }
    // 9B1A. Not sure what this actually is here
    break;}
    
    
    
    
    // =====================================================================
    // --------------------------------------------------------------
    case 2:{ // 9B2B
    set_xy(id, x,y-1);
    
    if (yt<=spawn_yt)
    {
        set_xlyt(id, xl,spawn_yt); // just in case
        
        Flash_timer = Flash_DUR; // $62
        global.pc.hspd   = 0;
        
        //aud_play_sound(mus_PlaceCrystal01_1); // This includes SND_STRK_SLD1 at the start
        aud_play_sound(get_audio_theme_track(dk_StrikeSolid));
        aud_play_sound(Fanfare_MUSIC, -1,false,-1, Fanfare_THEME);
        
        counter++;
    }
    
    canDrawCrystal = yt;
    break;}
    
    
    
    
    // =====================================================================
    // --------------------------------------------------------------
    case 3:{ // 9B47
    if (fanfare_failsafe_timer)
    {   fanfare_failsafe_timer--;  }
    
    if(!fanfare_failsafe_timer 
    || !audio_is_playing(Fanfare_MUSIC) )
    {
        g.StatRestore_timer_mp = get_stat_max(STR_Magic);
        g.StatRestore_timer_hp = get_stat_max(STR_Heart);
        
        counter++;
    }
    break;}
    
    
    
    
    // =====================================================================
    // --------------------------------------------------------------
    case 4:{ // 9B56
    if(!g.StatRestore_timer_mp 
    && !g.StatRestore_timer_hp )
    {
        g.pc_lock = 0;
        f.xpPending = f.xpNext - f.xp;
        
        // allow mus_rm_body to play again
        Audio.can_play_mus_rm_body = true;
        
        counter = 0; // Indicates crystal has been placed
        //counter = $FF; // Indicates crystal has been placed
    }
    break;}
}




