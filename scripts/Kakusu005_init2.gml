/// Kakusu005_init2()

// In PalcA, light all torches to reveal.


var _i,_j, _a;


                    _a=1;
SUB_STATE_CHLG_1A = _a++;
SUB_STATE_CHLG_1B = _a++;
SUB_STATE_ACTV    = _a++;
sub_state         = SUB_STATE_CHLG_1A;
sub_state_timer     = 0;



body_type = 1; // 1: Opaque, 2: Transparent
eyes_type = 2; // 1: EYES1(OG), 2: EYES2(cyclops)

abilities |= ABL_WALK;
abilities |= ABL_JUMP;
abilities |= ABL_RUN_;
abilities |= ABL_SHOT;

hspd_jump   = HSPD_JUMP_2;
vspd_jump   = VSPD_JUMP_HGH2;
VSPD_REVEAL = vspd_jump;
jump_chance = JUMP_CHANCE2; // JUMP_CHANCE2: $40


projectile_OBJ = Flame2;
projectile_VER = 1;
projectile     = projectile_OBJ;
projectile_ver = projectile_VER;



var _CLM = g.rm_clms>>1;
var _ROW = g.rm_rows>>1;
GROUND_ROW = find_row_solid(TID_SOLID1, _CLM,_ROW, 1,g.rm_rows, g.rm_rows-4);
GROUND_CLM = find_clm_solid(         0,    0,_ROW, 1,g.rm_clms, 8);


BreakTile_DEPTH = g.dl_TILE_DEPTHS[|g.dg_RmTile_Break[#$08,g.rm_rows-4]>>8];
for(_i=g.rm_clms-3; _i>=0; _i--)
{
    for(_j=g.rm_rows-1; _j>=0; _j--)
    {
        if (g.dg_RmTile_Break[#_i,_j])
        {
            BreakTile_DEPTH = g.dl_TILE_DEPTHS[|g.dg_RmTile_Break[#_i,_j]>>8];
            _i = -1;
            break;
        }
    }
}




ap_kakusu_index = 2; // KAKUSU02: Parapa Palace
Kakusu_init2();




