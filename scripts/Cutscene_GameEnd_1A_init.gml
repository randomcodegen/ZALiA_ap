/// Cutscene_GameEnd_1A_init()


// need this bc this is RM_NAME_NPALACE
//if (g.cutscene != g.CUTSCENE_GAME_END_1A)
if(!g.game_end_state)
{
    instance_destroy();
    exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
}

if (global.AP_connected)
{
    apclient_status_update(global.AP_CLIENT_STATUS_GOAL);
    show_debug_message("AP: Victory reported to server");
}

g.cutscene = g.CUTSCENE_GAME_END_1A;


Cutscene_init();


scr_step     = Cutscene_GameEnd_1A_update;
scr_draw     = Cutscene_GameEnd_1A_draw;
scr_inst_end = Cutscene_GameEnd_1A_end;


depth = DEPTH_ITEM;


with(HUD) instance_destroy();


audio_stop_sound(Audio.mus_rm_inst);
                 Audio.mus_rm_intr = 0;
                 Audio.mus_rm_body = 0;
//

TRIFORCE_SPR  = spr_Triforce_1a;
p.triforce_pi = global.PI_MOB_PUR;
//p.triforce_pi = PI_BGR_4;
dg_triforce   = ds_grid_create(3,3);

f.hp = get_stat_max(STR_Heart); // Prevent low hp beep
f.mp = get_stat_max(STR_Magic);




