/// Item_udp()


can_draw_self = true;



// ------------------------------------------------------------------------------
if (IS_HOLD_ITEM 
||  object_index==ItmD0 ) // ItmD0: Key
{
    if (sub_state==sub_state_HELD)
    {    draw_yoff =  0;  }
    else draw_yoff = -1;
}



// ------------------------------------------------------------------------------
switch(object_index)
{
    // --------------------------------------------------------
    // ------------------------------------------------
    case CONT_PIECE_OBJ_HP:{
    if (sub_state==sub_state_HELD)
    {
        var _IDX = max(cont_piece_cnt_hp()-1, 0);
            _IDX = _IDX mod f.CONT_PIECE_PER_HP;
            _IDX++;
            _IDX-=can_blink_container_piece();
        GO_set_sprite(id,g.dl_cont_spr_hp[|_IDX]);
    }
    else
    {   // 0: SMALL, 1: BIG
        // Small for $28-2F,$38-3F every $40
        var _IDX = $28;
            _IDX = g.counter0&_IDX == _IDX;
        GO_set_sprite(id,g.dl_HeartPiece_SPR[|sign(_IDX)]);
        //GO_set_sprite(id,g.dl_HeartPiece_SPR[|!sign(_IDX)]);
    }
    break;}
    
    
    
    
    
    // --------------------------------------------------------
    // ------------------------------------------------
    case CONT_PIECE_OBJ_MP:{
    if (sub_state==sub_state_HELD)
    {
        var _IDX = max(cont_piece_cnt_mp()-1, 0);
            _IDX = _IDX mod f.CONT_PIECE_PER_MP;
            _IDX++;
            _IDX-=can_blink_container_piece();
        GO_set_sprite(id,g.dl_cont_spr_mp[|_IDX]);
    }
    else
    {
        GO_set_sprite(id,g.SPR_CONT_PIECE_MP);
    }
    break;}
    
    
    
    
    
    // --------------------------------------------------------
    // ------------------------------------------------
    case ItmA7:{ // ItmK6: ITM_SWRD
    depth = depth_def;
    draw_yoff =  0;
    yScale    =  1;
    
    if (sub_state!=sub_state_HELD)
    {
        draw_yoff =  1;
        yScale    = -1;
        if(!is_undefined(dk_spawn))
        {
            var _OBJ = val(g.dm_spawn_DEFAULT[?dk_spawn+STR_obj_idx]);
            if (_OBJ 
            &&  _OBJ==object_index )
            {   // if it's in its vanilla location
                depth = DEPTH_BG6+1; // DEPTH_BG6+1: Behind bg but in front of bg wall
                draw_yoff = -4;
            }
        }
    }
    break;}
}









// --------------------------------------------------------
if (object_index==ItmA8) // RESCUE FAIRY
{
    if (g.counter1&$4) GO_set_sprite(id,g.dl_Fairy_SPRITES[|0]); // wings up
    else               GO_set_sprite(id,g.dl_Fairy_SPRITES[|1]); // wings down
    draw_yoff = get_fairy_yoff(3);
}






// --------------------------------------------------------
if (g.mod_MedicinePlantItem 
&&  ITEM_BIT==ITM_MEDI )
{
    GO_set_sprite(id,g.FlowerItemAnim_SPR1);
}

// AP: apply scouted sprite + item type once
if (sprite_index != spr_AP_Logo
&&  sub_state != sub_state_HELD
&&  global.AP_connected
&&  variable_global_exists("ap_scouted_item_types")
&&  variable_global_exists("AP_location_map")
&&  !is_undefined(SPAWN_DATAKEY))
{
    var _ap_id = global.AP_location_map[?SPAWN_DATAKEY];
    if (!is_undefined(_ap_id))
    {
        var _scouted_type = global.ap_scouted_item_types[?_ap_id];
        if (!is_undefined(_scouted_type) && _scouted_type != "")
        {
            ITEM_TYPE = _scouted_type;
            var _scouted_spr = global.ap_scouted_sprites[?_ap_id];
            if (!is_undefined(_scouted_spr) && _scouted_spr > 0)
                GO_set_sprite_index(_scouted_spr);
            // For keys, set ITEM_ID so Item_draw shows
            if (string_pos(STR_KEY, _scouted_type) == 1)
            {
                var _palace = string_copy(_scouted_type, string_length(STR_KEY) + 1, 2);
                ITEM_ID = STR_KEY + _palace + "01";
            }
        }
        else
        {
            var _scout_flags = global.ap_scouted_flags[?_ap_id];
            if (!is_undefined(_scout_flags) && _scout_flags > 0)
            {
                GO_set_sprite_index(spr_AP_Logo);
                // Flags are a bitmask (prog=0b01, useful=0b10) and
                if      (_scout_flags & 1) image_index = 2;
                else if (_scout_flags & 2) image_index = 1;
                else image_index = 0;
            }
        }
    }
}




