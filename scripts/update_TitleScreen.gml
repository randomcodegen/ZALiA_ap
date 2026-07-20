/// update_TitleScreen()


if (Input.Pause_pressed)
{
    if (global.ap_ever_connected)
    {
        room_goto_(rmB_FileSelect);
        g.MaskWideView_w = 0;
        g.MaskWideView   = 0;
    }
    // else: block — AP not yet connected; draw shows status
}


// ---------------------------------------------------------------------
var _RESET  = Audio.timing_sound_position_curr==0 
           || Audio.timing_sound_position_curr<Audio.timing_sound_position_prev;
    _RESET &= audio_is_playing(snd_Default_Title_no_volume);
//


if (_RESET) cycle_num++;
if (_RESET) counter = COUNTER_START; // COUNTER_START = -1
            counter++;

// counter starts at $100 in TitleScreen_Create
var _count = counter>>8;

// TITLE ---------------------------------------
if!(counter&$3) // every 4 frames
{
    if (_RESET)
    {
        title_y = TITLE_Y_RESET;
    }
    
    if (_count>=SCROLL2_DELAY  // story scroll. SCROLL2_DELAY=8
    ||  title_y>0 )            // title reveal scroll
    {
        title_y--;
    }
}


// STORY -----------------------------------------------------
story_y = title_y + STORY_YOFF;



// FG --------------------------------------------------------



// COVER -------------------------------------------------------
if (g.counter1>=4) cover_can_draw = false;
if (cover_can_draw) g.surf.draw_clear_color = p.C_BLK1;



// ********** End Step ***********
// SHOOTING STAR ---------------------------------------
if (cycle_num>1 
&&  counter==SSTAR_VISIBLE_DELAY )
{
    sstar_moveNum = 0;
}

sstar_can_draw = sstar_moveNum < SSTAR_MAX_MOVES;

if (_count==2 
&& !(counter&$3) 
&&  sstar_moveNum<SSTAR_MAX_MOVES )
{
    sstar_moveNum++;
}






/*
if(!(g.timer0&$7F)){
var _str  =   'viewXL() '+string(viewXL()) + ', viewYT() '+string(viewYT());
    _str += ', viewW() ' +string(viewW())  + ', viewH() ' +string(viewH());
    _str += ', room_width ' +string(room_width) + ', room_height '+string(room_height);
    _str += ', g.rm_w ' +string(g.rm_w) + ', g.rm_h ' +string(g.rm_h);
    _str += ', x '+string(x)+', y '+string(y);
sdm(_str);
}
*/
// viewXL() 16, viewYT() -17, viewW() 480, viewH() 270, room_width 512, room_height 256, g.rm_w 512, g.rm_h 256, x 112, y 46
// viewXL()  0, viewYT()   0, viewW() 480, viewH() 270, room_width 512, room_height 256, g.rm_w 512, g.rm_h 256, x 112, y 46










