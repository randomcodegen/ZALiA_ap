/// Item_update_1()

// E771, E77B. Acquiring item

var _MUSIC_THEME1 = dk_GetItem+"01";
var _MUSIC_THEME2 = dk_GetItem+"02";
var _can_flash=false;
var _ap_skip_grant = false;
if (global.AP_connected && variable_global_exists("AP_location_map"))
{
    _ap_skip_grant = !is_undefined(SPAWN_DATAKEY)
    && !is_undefined(global.AP_location_map[?SPAWN_DATAKEY])
    && !is_undefined(g.dm_spawn[?SPAWN_DATAKEY + STR_Item + STR_ID + STR_Randomized]);
}

// AP: send location check early (before switch)
if (global.AP_connected && !is_undefined(SPAWN_DATAKEY))
{
    ap_check_location(SPAWN_DATAKEY, ITEM_ID, g.rm_name, AP_spawn_x, AP_spawn_y);
}
else if (global.AP_connected && !is_undefined(ITEM_ID))
{
    // Fallback: use item ID for locations w/o
    ap_check_location(ITEM_ID, undefined, g.rm_name, AP_spawn_x, AP_spawn_y);
}

// Spell items placed by AP override (e.g
if (!is_undefined(ITEM_TYPE) && is_string(ITEM_TYPE))
{
    var _spell_bit = val(g.dm_Spell[?STR_Bit+ITEM_TYPE], -1);
    if (_spell_bit != -1 && !(f.spells & _spell_bit))
    {
        f.spells |= _spell_bit;
        _can_flash = true;
        show_debug_message("AP: Spell granted via pickup — bit $" + hex_str(_spell_bit) + " from ITEM_TYPE " + ITEM_TYPE);
    }
}

switch(ITEM_TYPE)
{
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_CANDLE:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_GLOVE:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_RAFT:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_HAMMER:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_BOOTS:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    Overworld_tile_change_2a(global.OVERWORLD.TileChangeEvent_TYPE_BOOT1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_FLUTE:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_BRACELET:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_CROSS:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    
    
    
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_RFAIRY:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    g.StatRestore_timer_hp = get_stat_max(STR_Heart);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_BOOK:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MEAT:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_PENDANT:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_SHIELD:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_SWORD:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_RING:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_ALLKEY:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MASK:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    
    
    
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_FEATHER:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MAP1:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME2), -1,false,-1, _MUSIC_THEME2);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MAP2:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME2), -1,false,-1, _MUSIC_THEME2);
    break;}
    
    
    
    
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_TROPHY:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_NOTE:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MIRROR:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_FLOWER:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_CHILD:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_BOTTLE:{
    if (!_ap_skip_grant) { f.items |= ITEM_BIT; }
    _can_flash=true;
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);
    break;}
    
    
    
    
    
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_HEART:{
    if (!_ap_skip_grant) { f.cont_pieces_hp += string_copy(ITEM_ID, string_length(ITEM_ID)-3, 4); }
    g.StatRestore_timer_hp = get_stat_max(STR_Heart);
    if!(cont_piece_cnt_hp() mod f.CONT_PIECE_PER) // if this completes a container
    {    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);  }
    else aud_play_sound(get_audio_theme_track(_MUSIC_THEME2), -1,false,-1, _MUSIC_THEME2);
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_MAGIC:{
    if (!_ap_skip_grant) { f.cont_pieces_mp += string_copy(ITEM_ID, string_length(ITEM_ID)-3, 4); }
    g.StatRestore_timer_mp = get_stat_max(STR_Magic);
    if!(cont_piece_cnt_mp() mod f.CONT_PIECE_PER) // if this completes a container
    {    aud_play_sound(get_audio_theme_track(_MUSIC_THEME1), -1,false,-1, _MUSIC_THEME1);  }
    else aud_play_sound(get_audio_theme_track(_MUSIC_THEME2), -1,false,-1, _MUSIC_THEME2);
    break;}
    
    
    
    
    
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_KEY:{ // E79A
    if(!is_undefined(ITEM_ID)  // key_datakey example: "0203", "0601"
    &&  is_string(   ITEM_ID) )
    {       if (!_ap_skip_grant) { f.dm_keys[?  ITEM_ID+STR_Acquired] = true; }  }
    
    if (!_ap_skip_grant) { f.key_count = get_key_count(g.dungeon_num); }
    aud_play_sound(get_audio_theme_track(dk_StabItem));
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_JAR:{ // E847
    g.StatRestore_timer_mp += get_jar_restore_dur(ver);
    
    if (ver==1 
    ||  ver==3 )
    {
        if(!is_undefined(ITEM_ID) 
        &&  is_string(   ITEM_ID) )
        {   if (!_ap_skip_grant) { f.dm_jars[?  ITEM_ID+STR_Acquired] = true; }  }
    }
    aud_play_sound(get_audio_theme_track(dk_StabItem));
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_PBAG:{ // E7F4: JSR E880
    // For that have a spawn datakey (not ones dropped by an enemy)
    if(!is_undefined(ITEM_ID) 
    &&  is_string(   ITEM_ID) )
    {   if (!_ap_skip_grant) { f.dm_PBags[? ITEM_ID+STR_Acquired] = true; }  }
    
    aud_play_sound(get_audio_theme_track(dk_StabItem));
    if (!_ap_skip_grant)
    {
        timer = g.XP_RISE_DURATION + 2; // $20 + 2
        state = state_DROP; // for xp rise
    }
    break;}
    
    // ===============================================================================
    // ------------------------------------------------------------------------
    case STR_1UP:{ // E80C
    if (!_ap_skip_grant) { lives++; }
    
    if(!is_undefined(  ITEM_ID) 
    &&  is_string(     ITEM_ID) )
    {
        if (!_ap_skip_grant) { f.dm_1up_doll[?ITEM_ID+STR_Acquired] = true; }
        //show_debug_message("Item_update_1(). "+"f.dm_1up_doll[?'"+ITEM_ID+"'+STR_Acquired] = true;");
    }
    
    aud_play_sound(get_audio_theme_track(_MUSIC_THEME2), -1,false,-1, _MUSIC_THEME2);
    break;}
}//switch(ITEM_TYPE1)



if (_can_flash)
{
    var                     _DURATION = p.SpellFlash_DURATION1; // SpellFlash_DURATION1=$20. bit $80 means flash background
    p.Flash_Pal_timer     = _DURATION;
    p.Flash_Bgr_timer     = _DURATION;
    p.SpellFlash_PC_timer = _DURATION;
}

// AP: Send location check (first call via




