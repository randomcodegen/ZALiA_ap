/// Kakusu014_init2()

// Block Matching Puzzle. Sitting on pillar. Needs block to crush it.


var                 _a=1;
//SUB_STATE_IDLE    = _a++;
SUB_STATE_SWITCH0 = _a++; // Off
SUB_STATE_SWITCH1 = _a++; // On (create blocks)
SUB_STATE_REVEAL  = _a++; // 
SUB_STATE_ACTV    = _a++;
sub_state         = SUB_STATE_SWITCH0;
sub_state_timer     = 0;


VSPD_REVEAL = vspd_jump;

hp_idx = HP_IDX;


DRAW_YOFF = 0;

body_type = 1; // 1: Opaque, 2: Transparent
eyes_type = 2; // 1: EYES1(OG), 2: EYES2(cyclops)



ap_kakusu_index = 10; // KAKUSU10: P6 (Three Eye Rock Palace)
Kakusu_init2();




