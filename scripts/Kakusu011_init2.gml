/// Kakusu011_init2()

// Kasuto Cemetery


var _i, _a;


                  _a=1;
SUB_STATE_SEQU  = _a++;
SUB_STATE_CMPL1 = _a++;
SUB_STATE_ACTV  = _a++;
sub_state       = SUB_STATE_SEQU;
sub_state_timer   =  0;


abilities |= ABL_WALK;
abilities |= ABL_JUMP;
abilities |= ABL_RUN_;
abilities |= ABL_SHOT;

body_type = 1; // 1: Opaque, 2: Transparent
eyes_type = 2; // 1: EYES1(OG), 2: EYES2(cyclops)


projectile_OBJ = Flame1;
projectile_VER = 1;
projectile     = projectile_OBJ;
projectile_ver = projectile_VER;


hspd_jump   = HSPD_JUMP_2;
vspd_jump   = VSPD_JUMP_HGH2;
VSPD_REVEAL = vspd_jump;
jump_chance = JUMP_CHANCE2; // JUMP_CHANCE2: $40



ap_kakusu_index = 11; // KAKUSU11: Kasuto Cemetery
Kakusu_init2();




