/// Kakusu003_init2()

// behavior: Still. Can only die from a downthrust from high enough.


body_type = 1; // 1: Opaque, 2: Transparent
eyes_type = 2; // 1: EYES1(OG), 2: EYES2(cyclops)

HP_IDX = ds_list_size(g.dl_HP)-1;
hp_idx = HP_IDX;

is_idle = true;

    drop_dist = $10<<3; // PC drop dist
if(!is_undefined(dk_spawn))
{   drop_dist = val(g.dm_spawn[?dk_spawn+STR_Distance], drop_dist);  }


ap_kakusu_index = 6; // KAKUSU06: P3 (Island Palace)
Kakusu_init2();




