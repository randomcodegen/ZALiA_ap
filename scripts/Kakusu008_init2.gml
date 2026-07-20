/// Kakusu008_init2()

// Dark Forest tile in Darunia Forest


hspd_jump   = HSPD_JUMP_2;
vspd_jump   = VSPD_JUMP_HGH2;
jump_chance = JUMP_CHANCE2; // JUMP_CHANCE2: $40


abilities |= ABL_WALK;
abilities |= ABL_JUMP;
abilities |= ABL_RUN_;
abilities |= ABL_SHOT;

body_type = 1; // 1: Opaque, 2: Transparent
eyes_type = 2; // 1: EYES1(OG), 2: EYES2(cyclops)


projectile_OBJ = Flame2;
projectile_VER = 1;
projectile     = projectile_OBJ;
projectile_ver = projectile_VER;



ap_kakusu_index = 8; // KAKUSU08: Darunia Forest
Kakusu_init2();




