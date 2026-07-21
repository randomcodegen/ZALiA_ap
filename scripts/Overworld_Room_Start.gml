/// Overworld_Room_Start()

show_debug_message("Overworld_Room_Start()");


if (g.room_type!="C") exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




var _i,_j, _a, _val, _num, _count,_count1,_count2;
var _str, _spawn_datakey, _datakey, _dk1,_dk2,_dk3;
var _owrc, _owrc_, _ow_x,_ow_y;
var _clm,_row;
var _rm_name;
var _item_id,_item_type, _qual_quests,_quest_num, _map_num, _acquired;


room_width      = DRAW_W;
room_height     = DRAW_H;
view_xview[0]   = CAM_X;
view_yview[0]   = CAM_Y;

exit_owrc       = 0;
pc_x_scale      = 1;
mot             = 0; // mot: Mode Of Transportation.  0: not moving
dest_dist       = 0;
pc_step_counter = 1;

move_spd        = 0; // 0: no movement
move_x          = 0;
move_y          = 0;
move_step       = 1;
move_speed      = 0.0;
move_distance   = 0.0;

flute_timer = 0; // 0566

Warp_state = 0;
Warp_is_warping = false;
Warp_timer = 0;
Warp_owrc  = $0000;
Warp_x     = 0;
Warp_y     = 0;
Warp_yoff  = 0;
Warp_speed = 0;
Warp_destination_num = 0;

BAIT_timer = 0;
BAIT_owrc  = $0000;
BAIT_ow_x  = 0;
BAIT_ow_y  = 0;




// enc_spawn_timer decrements every $14 frames when g.timer_b reaches -1 in update_game_timers()
enc_spawn_timer     = 8;
enc_spawn_timer    += enc_spawn_timer_add; // 2022/12/05. Attempting to balance enc difficulty
enc_spawn_timer_add = 0;
ds_grid_clear(dg_enc_inst,0);

enc_reen = undefined; // reen: Room-Entry Exit-Name

// pcrc & pc_dir are set in update_change_room_1a() when leaving rmA
if(!pc_dir) pc_dir = $1;
//pc_spr = dg_pc_spr[#bitNum(pc_dir)-1, 0];




if (room==FileSelect)
{
    global.can_rando_ow_tsrc = false;
    ds_map_clear(dm_Rando_TSRC);
    //ds_map_clear(dm_rando_biome);
}

/*
if(!val(f.dm_rando[?STR_Randomize+STR_Item+STR_Locations]))
{
    _count = val(dm[?STR_Rando+STR_Exit+STR_Count]);
    for(_i=1; _i<=_count; _i++)
    {
        _owrc = dm[?STR_Rando+STR_Exit+hex_str(_i)+STR_OWRC];
        if(!is_undefined(_owrc))
        {
            _clm = (_owrc>>0)&$FF;
            _row = (_owrc>>8)&$FF;
            dg_tsrc[# _clm,_row] = (TILESET1_TS_IDX<<8)|TSRC_MOUN01;
            dg_solid[#_clm,_row] = $01;
            dm[?hex_str(_owrc)+STR_Open] = 0;
        }
    }
}
*/




pcrc_spawn  =  pcrc;
pcrc_map    =  pcrc;

var _PC_CLM = (pcrc>>0)&$FF;
var _PC_ROW = (pcrc>>8)&$FF;

_ow_x = ((_PC_CLM<<SHIFT) + (T_SIZE>>1)) - DRAW_W_;
_ow_y = ((_PC_ROW<<SHIFT) + (T_SIZE>>1)) - DRAW_H_;

Overworld_refresh_tiles(_ow_x,_ow_y);


change_pal(strReplaceAt(p.pal_rm_new, get_pal_pos(ENC_PI), string_length(ENC_PAL), ENC_PAL));
/*
var _POS  = val(p.dm_pal_data[?hex_str(ENC_PI)+STR_Palette+STR_Position], p.PAL_POS_MOB4);
var _LEN  = string_length(ENC_PAL);
    _POS += global.PAL_CHAR_PER_PAL-_LEN;
change_pal(strReplaceAt(p.pal_rm_new, _POS, _LEN, ENC_PAL));
*/


WaterSparkle_refresh(pcrc);








// ----------------------------------------------------------------------
ds_grid_clear(TreasureMaps_dg,0);

if (f.items&(ITM_MAP1|ITM_MAP2))
{
    var _dg_map_HEIGHT = ds_grid_height(TreasureMaps_dg);
    ds_grid_resize(TreasureMaps_dg,0,_dg_map_HEIGHT);
    //sdm("_dg_map_HEIGHT: $"+hex_str(_dg_map_HEIGHT)+",  f.items&ITM_MAP1="+string(f.items&ITM_MAP1)+",  f.items&ITM_MAP2="+string(f.items&ITM_MAP2));
    
    for(_i=ds_list_size(g.dl_MapItem_ITEM_IDS)-1; _i>=0; _i--)
    {
        _item_id   =    g.dl_MapItem_ITEM_IDS[|_i];
        _item_type = string(val(g.dm_spawn[?_item_id+STR_Item+STR_Type]));

        // The AP-aware rando markers (ItemAcquiredIndicator) now
        if (_item_type != STR_Kakusu
        && (val(global.dm_save_file_settings[?STR_Randomize+STR_Item+STR_Locations])
        ||  val(global.dm_save_file_settings[?STR_Randomize+STR_PBAG+STR_Locations])
        ||  val(global.dm_save_file_settings[?STR_Randomize+STR_Key +STR_Locations]) ))
        {
            continue;//_i
        }

        if (_item_type==STR_KEY)
        {
            if(!val(global.dm_save_file_settings[?STR_Randomize+STR_Key+STR_Locations]) 
            || !g.RandoKeys_MAP_items_show_keys )
            {
                continue;//_i
            }
        }
        
             _map_num = val(g.dm_spawn[?_item_id+STR_Map+STR_Num]);
        if ((_map_num==1 && f.items&ITM_MAP1) 
        ||  (_map_num==2 && f.items&ITM_MAP2) )
        {
            _datakey = _item_id+STR_Spawn+STR_Datakey;
            switch(_item_type){
            case STR_HEART: {if (val(global.dm_save_file_settings[?STR_Randomize+STR_Item  +STR_Locations])){_datakey+=STR_Randomized;} break;}
            case STR_MAGIC: {if (val(global.dm_save_file_settings[?STR_Randomize+STR_Item  +STR_Locations])){_datakey+=STR_Randomized;} break;}
            case STR_1UP:   {if (val(global.dm_save_file_settings[?STR_Randomize+STR_Item  +STR_Locations])){_datakey+=STR_Randomized;} break;}
            case STR_Kakusu:{if (val(global.dm_save_file_settings[?STR_Randomize+STR_Kakusu+STR_Locations])){_datakey+=STR_Randomized;} break;}
            case STR_KEY:   {if (val(global.dm_save_file_settings[?STR_Randomize+STR_Key   +STR_Locations])){_datakey+=STR_Randomized;} break;}
            }
            _spawn_datakey =     g.dm_spawn[?_datakey];
            _qual_quests   = val(g.dm_spawn[?_item_id+STR_Qualified+STR_Quest+STR_Nums], hex_str(f.quest_num));
            
            if (string_pos(hex_str(f.quest_num),_qual_quests) 
            && !is_undefined(_spawn_datakey) )
            {
                if (string_pos(STR_Kakusu,_item_id))
                {   // if defeated
                    if (val(f.dm_kakusu[?_spawn_datakey])) continue;//_i
                }
                else
                {   // CONTAINER PIECES, 1UPS, KEYS
                    // AP mode: use checked list instead of local
                    if (global.AP_connected && variable_global_exists("ap_checked_ids") && variable_global_exists("AP_location_map"))
                    {
                        var _ap_id2 = global.AP_location_map[?_spawn_datakey];
                        if (!is_undefined(_ap_id2) && ds_list_find_index(global.ap_checked_ids, _ap_id2) != -1) continue;
                    }
                    else if (item_acquired(_item_id)) continue;//_i
                }
                
                _rm_name = val(g.dm_spawn[?_spawn_datakey+STR_Rm+STR_Name], "undefined");
                
                // Make a default owrc right outside North Castle so errors are obvious.
                _owrc  = ((OW_ROWS>>1)&$FF)<<8;
                _owrc |= ((OW_CLMS>>1)&$FF)<<0;
                _owrc  = val(g.dm_spawn[?MK_OWRC_NPAL1], _owrc);
                _owrc += $0008; // horizontal
                _owrc -= $0400; // vertical
                
                //_owrc  = val(dm[?_rm_name+STR_OWRC], _owrc);
                _owrc  = val(g.dm_rm[?   _rm_name+STR_OWRC], _owrc);
                _owrc  = val(f.dm_rando[?_rm_name+STR_OWRC], _owrc);
                _ow_x  = (((_owrc>>0)&$FF) <<4) + 8;
                _ow_y  = (((_owrc>>8)&$FF) <<4) + 8;
                
                ds_grid_resize(TreasureMaps_dg,ds_grid_width(TreasureMaps_dg)+1,_dg_map_HEIGHT);
                _idx = ds_grid_width(TreasureMaps_dg)-1;
                TreasureMaps_dg[#_idx,$0] = _spawn_datakey;
                TreasureMaps_dg[#_idx,$1] = _owrc;
                TreasureMaps_dg[#_idx,$2] = _ow_x;
                TreasureMaps_dg[#_idx,$3] = _ow_y;
                TreasureMaps_dg[#_idx,$4] = val(g.dm_spawn[?_item_id+STR_Object]);
                TreasureMaps_dg[#_idx,$6] = val(g.dm_spawn[?_item_id+STR_Map+STR_Num]);
                TreasureMaps_dg[#_idx,$7] = _item_id;
                TreasureMaps_dg[#_idx,$8] = _item_type;
                TreasureMaps_dg[#_idx,$9] = false; // $9: can draw
                //sdm(_item_id+string_repeat(" ",$A-string_length(_item_id))+", owrc $"+hex_str(_owrc)+", ow_x $"+hex_str(_ow_x)+", ow_y $"+hex_str(_ow_y)+", _spawn_datakey "+_spawn_datakey+", _map_num "+string(_map_num)+", _qual_quests "+_qual_quests);
            }
        }
    }
}








if (val(global.dm_save_file_settings[?STR_Randomize+STR_Item+STR_Locations]))
{
    var _dm1=ds_map_create();
    var _c1=false;
    ds_map_clear(dm_rando_locations);
    
                  _count = val(f.dm_rando[?STR_Total+STR_Location+STR_Count]);
    for(_i=1; _i<=_count; _i++)
    {
        _c1 = false;
        _acquired = false;
        _rm_name = undefined;
        _datakey = STR_Location+hex_str(_i);

        // Resolve the authoritative AP id and confirm
        var _ap_loc_id = 387642575169 + (_i - 1);
        var _ap_loc_desc = f.dm_rando[?_datakey+STR_Description];
        var _ap_loc_valid = true;
        var _ap_manifest_ready = global.AP_connected
            && variable_global_exists("ap_created_manifest_ready")
            && global.ap_created_manifest_ready;
        if (_ap_manifest_ready)
        {
            var _manifest_id = ds_map_find_value(global.ap_created_location_indices, _i);
            _ap_loc_valid = !is_undefined(_manifest_id);
            if (_ap_loc_valid) _ap_loc_id = real(_manifest_id);
        }
        var _ap_loc_map_ready = global.AP_connected
            && variable_global_exists("ap_location_name_to_id")
            && !is_undefined(global.ap_location_name_to_id)
            && global.ap_location_name_to_id != -1;
        if (!_ap_manifest_ready && _ap_loc_map_ready)
        {
            _ap_loc_valid = false;
            var _ap_is_kakusu = !is_undefined(_ap_loc_desc)
                && string_pos("Kakusu ",_ap_loc_desc) == 1;

            // Individual Kakusu checks are AP-only and
            if (_ap_is_kakusu
            &&  variable_global_exists("ap_kakusu_selected")
            && !is_undefined(global.ap_kakusu_selected)
            &&  variable_global_exists("ap_kakusu_id_by_index")
            && !is_undefined(global.ap_kakusu_id_by_index))
            {
                var _ap_kak_idx = real(string_copy(_ap_loc_desc,8,
                    string_length(_ap_loc_desc)-7));
                var _ap_kak_selected = ds_map_find_value(global.ap_kakusu_selected,
                    string(_ap_kak_idx));
                var _ap_kak_id = ds_map_find_value(global.ap_kakusu_id_by_index,
                    string(_ap_kak_idx));
                if (!is_undefined(_ap_kak_selected) && !is_undefined(_ap_kak_id))
                {
                    _ap_loc_id = real(_ap_kak_id);
                    _ap_loc_valid = true;
                    if (variable_global_exists("ap_id_to_location_name")
                    && !is_undefined(global.ap_id_to_location_name))
                    {
                        var _ap_kak_name = ds_map_find_value(global.ap_id_to_location_name,
                            _ap_loc_id);
                        if (!is_undefined(_ap_kak_name)) _ap_loc_desc = _ap_kak_name;
                    }
                }
            }
            else if (!is_undefined(_ap_loc_desc) && _ap_loc_desc != "")
            {
                var _ap_loc_mapped = ds_map_find_value(global.ap_location_name_to_id, _ap_loc_desc);
                if (!is_undefined(_ap_loc_mapped))
                {
                    _ap_loc_id = real(_ap_loc_mapped);
                    _ap_loc_valid = true;
                }
            }
            if (!_ap_loc_valid && !_ap_is_kakusu)
            {
                var _ap_rev_name = ds_map_find_first(global.ap_location_name_to_id);
                while (!is_undefined(_ap_rev_name))
                {
                    var _ap_rev_id = real(global.ap_location_name_to_id[?_ap_rev_name]);
                    if (_ap_rev_id == _ap_loc_id)
                    {
                        _ap_loc_desc = _ap_rev_name;
                        _ap_loc_id = _ap_rev_id;
                        _ap_loc_valid = true;
                        break;
                    }
                    _ap_rev_name = ds_map_find_next(global.ap_location_name_to_id, _ap_rev_name);
                }
            }
        }
        if (!_ap_loc_valid) continue;
        _item_id = f.dm_rando[?_datakey+STR_Item+STR_ID+STR_Randomized];
        if(!is_undefined(_item_id))
        {
            _item_type = string(val(g.dm_spawn[?_item_id+STR_Item+STR_Type]));
            switch(_item_type){
            default:      {_c1=true; break;}
            case STR_PBAG:{_c1=val(global.dm_save_file_settings[?STR_Randomize+STR_PBAG+STR_Locations]); break;}
            case STR_KEY: {_c1=val(global.dm_save_file_settings[?STR_Randomize+STR_Key +STR_Locations]); break;}
            }
            
            if (_c1)
            {
                // Anchor the mark to THIS location, not to
                _spawn_datakey = g.dm_spawn[?_item_id+STR_Spawn+STR_Datakey+STR_Randomized];
                if(!is_undefined(_spawn_datakey) && _spawn_datakey!="undefined")
                    _rm_name = g.dm_spawn[?_spawn_datakey+STR_Rm+STR_Name];
                // Individual Kakusu checks spawn their reward via
                if (is_undefined(_rm_name))
                    _rm_name = f.dm_rando[?_datakey+STR_Rm+STR_Name];
            }
        }

        // The server-created manifest decides whether this is a check. 
        // Native randomized-item data only helps identify its physical spawn.
        if (_ap_manifest_ready)
        {
            _c1 = true;
            if (is_undefined(_rm_name))
                _rm_name = f.dm_rando[?_datakey+STR_Rm+STR_Name];
            // This cave's check lives in the side-view room but its map icon
            // belongs to the adjacent overworld entrance.
            if (_rm_name == Area_EastA+'0C') _rm_name = Area_EastA+'0B';
        }

        // A real AP-created location may have no
        if (is_undefined(_item_id) && global.AP_connected
        &&  variable_global_exists("ap_scouted_flags"))
        {
            var _missing_home = f.dm_rando[?_datakey+STR_Rm+STR_Name];
            if (!is_undefined(_missing_home)
            && !is_undefined(global.ap_scouted_flags[?_ap_loc_id]))
            {
                _c1 = true;
                _rm_name = _missing_home;
                // Kasuto Swamp cave 1b has no direct overworld
                if (_missing_home == Area_EastA+'0C') _rm_name = Area_EastA+'0B';
            }
        }

        if (!is_undefined(_rm_name))
        {
            _owrc = g.dm_rm[?_rm_name+STR_OWRC];
            _owrc = val(f.dm_rando[?_rm_name+STR_OWRC], _owrc);
            if(!is_undefined(_owrc))
            {
                _owrc_ = hex_str(_owrc);
                
                // AP mode: count checked locations, not locally
                if (global.AP_connected && variable_global_exists("ap_checked_ids"))
                {
                    _acquired = sign(ds_list_find_index(global.ap_checked_ids, _ap_loc_id) != -1);
                }
                else
                {
                    _acquired = sign(item_acquired(_item_id));
                }
                dm_rando_locations[?_datakey+STR_OWRC] = _owrc;
                dm_rando_locations[?_datakey+"_AP_ID"] = _ap_loc_id;
                dm_rando_locations[?_datakey+"_AP_DESC"] = _ap_loc_desc;
                dm_rando_locations[?_datakey+STR_Acquired] = _acquired;
                
                _count1 = val(dm_rando_locations[?_owrc_+STR_Item+STR_Count]) + 1;
                dm_rando_locations[?_owrc_+STR_Item+STR_Count] = _count1;
                
                _count2 = val(dm_rando_locations[?_owrc_+STR_Acquired+STR_Count]) + _acquired;
                dm_rando_locations[?_owrc_+STR_Acquired+STR_Count] = _count2;
                
                
                if (is_undefined(_dm1[?_owrc_]))        _dm1[?_owrc_]  = $0000;
                     if (!is_undefined(_item_id) && string_pos(STR_PBAG,_item_id)) _dm1[?_owrc_] |= $0100;
                else if (!is_undefined(_item_id) && string_pos(STR_KEY, _item_id)) _dm1[?_owrc_] |= $0010;
                else                                    _dm1[?_owrc_] |= $0001;
                if (bitCount(val(_dm1[?_owrc_]))>1) dm_rando_locations[?_owrc_+STR_Varied] = true;
                            /*
                            _str  = "item: "+string(val(_item_id));
                            _str += string_repeat(" ",$A-string_length(string(val(_item_id))));
                            _str += ", "+"spawn_dk: "+string(val(_spawn_datakey));
                            _str += ", "+"rm: "+string(val(_rm_name));
                            _str += ", "+STR_Location+hex_str(_i)+STR_OWRC+" $"+_owrc_;
                            _str += ", "+"count1 $"+hex_str(_count1)+" count2 $"+hex_str(_count2);
                            sdm(_str);
                            if!(_i&$3) sdm("");
                            */
            }
        }
    }

    // Boss-item checks are AP-only virtual locations, so the native location
    // loop above cannot count them.  Attach one to each crystal palace's
    // physical overworld tile when the option is enabled.
    var _ap_boss_items_on = false;
    if (global.AP_connected && variable_global_exists("ap_slot_data")
    && !is_undefined(global.ap_slot_data))
    {
        var _ap_boss_opt = ds_map_find_value(global.ap_slot_data, "boss_item_locations");
        _ap_boss_items_on = !is_undefined(_ap_boss_opt) && real(_ap_boss_opt);
    }
    if (_ap_boss_items_on)
    {
        var _ap_boss_dungeon, _ap_boss_id, _ap_boss_home, _ap_boss_key;
        for (_ap_boss_dungeon = 1; _ap_boss_dungeon <= 6; _ap_boss_dungeon++)
        {
            _ap_boss_id = undefined;
            if (variable_global_exists("ap_boss_item_location_ids")
            && !is_undefined(global.ap_boss_item_location_ids))
                _ap_boss_id = ds_map_find_value(global.ap_boss_item_location_ids,
                    string(_ap_boss_dungeon));
            if (is_undefined(_ap_boss_id))
                _ap_boss_id = 387642575169 + 192 + _ap_boss_dungeon;
            if (_ap_manifest_ready
            && is_undefined(ds_map_find_value(global.ap_created_location_ids, real(_ap_boss_id))))
                continue;

            switch (_ap_boss_dungeon)
            {
                case 1: _ap_boss_home = Area_PalcA+'00'; break;
                case 2: _ap_boss_home = Area_PalcB+'00'; break;
                case 3: _ap_boss_home = Area_PalcC+'00'; break;
                case 4: _ap_boss_home = Area_PalcD+'00'; break;
                case 5: _ap_boss_home = Area_PalcE+'00'; break;
                case 6: _ap_boss_home = Area_PalcF+'00'; break;
            }
            _owrc = val(f.dm_rando[?_ap_boss_home+STR_OWRC],
                g.dm_rm[?_ap_boss_home+STR_OWRC]);
            if (is_undefined(_owrc)) continue;
            _owrc_ = hex_str(_owrc);
            _acquired = sign(ds_list_find_index(global.ap_checked_ids, real(_ap_boss_id)) != -1);
            _ap_boss_key = "_AP_BOSS_ITEM_" + string(_ap_boss_dungeon);
            dm_rando_locations[?_ap_boss_key+STR_OWRC] = _owrc;
            dm_rando_locations[?_ap_boss_key+"_AP_ID"] = real(_ap_boss_id);
            dm_rando_locations[?_ap_boss_key+STR_Acquired] = _acquired;
            dm_rando_locations[?_owrc_+STR_Item+STR_Count]
                = val(dm_rando_locations[?_owrc_+STR_Item+STR_Count]) + 1;
            dm_rando_locations[?_owrc_+STR_Acquired+STR_Count]
                = val(dm_rando_locations[?_owrc_+STR_Acquired+STR_Count]) + _acquired;
        }
    }

    ds_map_destroy(_dm1); _dm1=undefined;
}








var _all_conditions_met = true;

for(_i=1; _i<=6; _i++)
{
    _dk1 = STR_Dungeon+hex_str(_i);
    _datakey = _dk1+"_FullCleared";
    if(!val(f.dm_quests[?_datakey]))
    {
        _all_conditions_met = crystal_is_placed(_i);
        
        if (_all_conditions_met)
        {
            _dk2 = _dk1+STR_Item;
            _count1 = val(g.dm_spawn[?_dk2+STR_Count]);
            if (_count1)
            {
                for(_j=1; _j<=_count1; _j++)
                {
                    if(!_all_conditions_met)
                    {
                        break;//_j
                    }
                    
                    _dk3 = _dk2+hex_str(_j);
                    //_item_type = g.dm_spawn[?_dk3+STR_Item+STR_Type];
                    _spawn_datakey = g.dm_spawn[?_dk3+dk_SpawnDatakey];
                    if(!is_undefined(_spawn_datakey))
                    //&& !is_undefined(_item_id) )
                    //&& !is_undefined(_item_type) )
                    {
                        _spawn_datakey = val(g.dm_spawn[?_spawn_datakey+STR_Spawn+STR_Datakey+STR_Randomized], _spawn_datakey);
                        
                        _item_id =           g.dm_spawn[?_dk3+STR_Item+STR_ID];
                        _item_id =       val(g.dm_spawn[?_spawn_datakey+STR_Item+STR_ID+STR_Randomized], _item_id);
                        if(!is_undefined(_item_id) 
                        &&  val(g.dm_spawn[?_spawn_datakey+STR_Dungeon+STR_Num])==_i )
                        {
                            _item_type = g.dm_spawn[?_item_id+STR_Item+STR_Type];
                            if(!is_undefined(_item_type))
                            //&&  _item_type!=STR_1UP 
                            //&&  _item_type!=STR_KEY 
                            //&&  _item_type!=STR_PBAG 
                            //&&  _item_type!=STR_JAR )
                            {
                                switch(_item_type){
                                default:        {_all_conditions_met=item_acquired(_item_id); break;}
                                case STR_HEART: {_all_conditions_met=item_acquired(_item_id); break;}
                                case STR_MAGIC: {_all_conditions_met=item_acquired(_item_id); break;}
                                //case STR_1UP:   {break;}
                                case STR_Kakusu:{_all_conditions_met=val(f.dm_kakusu[?_spawn_datakey]); break;}
                                //case STR_KEY:   {break;}
                                //case STR_PBAG:  {break;}
                                //case STR_JAR:   {break;}
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (_all_conditions_met)
        {
            f.dm_quests[?_datakey] = true;
        }
    }
}







/*
if(0){var _str="";
    for(_i=ds_grid_width(TreasureMaps_dg)-1; _i>=0; _i--){
        _str ="$"+hex_str(_i)+":  ";
        _str+="spawn_datakey: '"+string(TreasureMaps_dg[#_i,$00])+"'";
        _str+=", owrc $"+hex_str(TreasureMaps_dg[#_i,$01]);
        _str+=", obj: '"+obj_name(TreasureMaps_dg[#_i,$04])+"'";
        _str+=", acquired "+string(TreasureMaps_dg[#_i,$05]);
        _str+=", map "+string(TreasureMaps_dg[#_i,$06]);
        sdm(_str);
    }
}
*/

//for (_i=0; _i<8; _i++) sdm(STR_Boulder+STR_Circle+STR_Order+hex_str(_i+1)+": "+string(val(f.dm_quests[?STR_Boulder+STR_Circle+STR_Order+hex_str(_i+1)], "undefined")));
//Overworld_Room_Start_debug_1a(_ow_x,_ow_y, _PC_CLM,_PC_ROW);
//debug_ow_solids_1a(); // Outputs a visual representation of the ow with a grid a solid values




