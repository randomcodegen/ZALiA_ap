/// FileSelect_RandoStateMAIN_update()


// InputConfirm_pressed: Attack/Start button pressed
var _InputConfirm_pressed2 = InputConfirm_pressed || input_right_pressed;
var _InputConfirm_pressed3 = InputConfirm_pressed || Input.pressedH;


// -------------------------------------------------------------------------------
if (InputBack_pressed 
||  (RandoMAIN_cursor==RandoMAIN_BACK && InputConfirm_pressed) )
{
    //aud_play_sound(get_audio_theme_track(dk_ChooseChar));
    cue_change_state = CUE_CHANGE_STATE_1A;
    cue_cover_start  = CUE_COVER_START_1A;
    cue_cover_stop   = CUE_COVER_STOP_1A;
    
    aud_play_sound(get_audio_theme_track(BACK_SOUND_THEME1));
    g.counter1 = 0;
    state_previous = state;
    state_pending  = State_REGISTER;
    state          = State_NULL;
    exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}




// -------------------------------------------------------------------------------
if (input_select_pressed 
||  Input.pressedV )
{
    var _DIR = sign_(input_select_pressed || input_down_pressed);
    for(_i=0; _i<RandoMAIN_COUNT; _i++)
    {
        RandoMAIN_cursor = (RandoMAIN_cursor+_DIR+RandoMAIN_COUNT) mod RandoMAIN_COUNT;
        if (dg_RandoMAIN_Options[#RandoMAIN_cursor,2]>=0) break; // option is available
    }
    aud_play_sound(get_audio_theme_track(CURSOR_SOUND_THEME2));
    exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}








// -------------------------------------------------------------------------------
switch(RandoMAIN_cursor)
{
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_ITEMS:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        if (variable_global_exists("AP_connected") && global.AP_connected)
        {
            dg_RandoITEM_Options[#RandoITEM_LOCS, 2] = 1;
        }
        RandoState = RandoState_ITEM;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_SPELLS:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        RandoState = RandoState_SPELL;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_DUNGEONS:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        RandoState = RandoState_DUNGEON;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_ENEMIES:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        RandoState = RandoState_ENEMY;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_LVLCOST:{
    if (_InputConfirm_pressed3)
    {
        dg_RandoMAIN_Options[#RandoMAIN_cursor,2] = !dg_RandoMAIN_Options[#RandoMAIN_cursor,2]; // 2: state
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_XP:{
    if (_InputConfirm_pressed3)
    {
        dg_RandoMAIN_Options[#RandoMAIN_cursor,2] = !dg_RandoMAIN_Options[#RandoMAIN_cursor,2]; // 2: state
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_OTHER:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        RandoOTHER_MAIN_cursor       = 0;
        RandoOTHER_ITEMS_cursor      = 0;
        RandoOTHER_ITEMS_item_cursor = 0;
        RandoOTHER_SPELLS_cursor     = 0;
        RandoOTHER_REQUIRE_cursor    = 0;
        
        RandoState = RandoState_OTHER;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
    
    
    // ============================================================================
    // -------------------------------------------------------------------
    case RandoMAIN_SEED:{
    if (InputConfirm_pressed)
    {
        aud_play_sound(get_audio_theme_track(CONFIRM_SOUND_THEME1));
        RandoSEED_EDIT_state = 0;
        RandoSeedChar_cursor = 0;
        RandoSEED_cursor     = 0;
        
        RandoState = RandoState_SEED;
        FileSelect_Rando_cursor_reset(RandoState);
    }
    break;}
}




