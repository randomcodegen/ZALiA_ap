/// go_spawn_priorities()


var _i, _val, _count,_count1,_count2;
var _xl,_yt;
var _str, _datakey1, _dk_spawn,_dk_spawn1,_dk_spawn2;
var _obj,_obj1,_obj2, _ver, _obj_name, _objver, _obj_prefix;
var _item_id, _item_type;
var _scene_name, _qual;
var _RM_SPAWN_COUNT_PRIO = ds_grid_width(g.dg_spawn_prio);
if (global.SceneRando_enabled) var _SCENE_USED = val(f.dm_rando[?dk_SceneRando+STR_Scene+STR_Randomized+g.rm_name], g.rm_name);
else                           var _SCENE_USED = g.rm_name;





//  --------------------------------------------------------------------------
//  ------------  Items  --------------------------------------------
for(_i=0; _i<_RM_SPAWN_COUNT_PRIO; _i++)
{
    _dk_spawn = g.dg_spawn_prio[#_i,0];
    _obj      = g.dm_spawn[?_dk_spawn+STR_obj_idx];
    //sdm("_i $"+hex_str(_i)+", _dk_spawn "+string(_dk_spawn)+", obj "+obj_name(_obj)+" - "+obj_name(g.dg_spawn_prio[#_i,1]));
    
    
    if (is_undefined(_obj)
    || !is_ancestor( _obj,Item) )
    {
        show_debug_message("AP_PRIO_SKIP_NONITEM: dk=" + string(_dk_spawn) + " obj=" + string(_obj));
        continue;//_i
    }
    
    
    
    _item_id = undefined;
    
    
    _obj = g.dg_spawn_prio[#_i,1];
    _ver = g.dg_spawn_prio[#_i,3];
    _xl  = g.dg_spawn_prio[#_i,4];
    _yt  = g.dg_spawn_prio[#_i,6];
    
    
    _obj_name   = object_get_name(_obj);
    _objver     = _obj_name+hex_str(_ver);
    _obj_prefix = string_copy(_obj_name, 1, string_length(_obj_name)-1);
    
    
    _item_id = g.dm_spawn[?_dk_spawn+STR_Item+STR_ID+STR_Randomized];
    if (is_undefined(_item_id))
    {
        _item_id = g.dm_spawn[?_dk_spawn+STR_Item+STR_ID];
        if (is_undefined(_item_id))
        {
            show_debug_message("AP_PRIO_SKIP_NOITEM: dk=" + string(_dk_spawn) + " obj=" + string(_obj));
            continue;//_i
        }
    }
    
    
    _item_type = g.dm_spawn[?_dk_spawn+STR_Item+STR_Type];
    if (is_undefined(_item_type))
    {
        _item_type = g.dm_ITEM[?_obj_name+STR_Item+STR_Type];
        if (is_undefined(_item_type)) continue;//_i
    }
    
    
    //sdm("_item_id: "+_item_id+", item_acquired(_item_id): "+string(item_acquired(_item_id))+", f.cont_pieces_mp: "+f.cont_pieces_mp);
    // Skip spawn if location already checked.
    // In AP mode the local-rando _item_id
    // location (the AP srv may have
    // locally-placed one may have been granted
    // on AP location-checked state, not on
    // grant of the locally-placed item from
    // suppresses the spawn here even though
    var _skip_spawn = false;
    if (global.AP_connected && variable_global_exists("ap_checked_ids") && variable_global_exists("AP_location_map"))
    {
        var _ap_id = global.AP_location_map[?_dk_spawn];
        // Fallback: item_id key (matches Rando_set_data_1a's secondary
        if (is_undefined(_ap_id) && !is_undefined(_item_id))
            _ap_id = global.AP_location_map[?_item_id];
        if (!is_undefined(_ap_id) && ds_list_find_index(global.ap_checked_ids, _ap_id) != -1)
        {
            _skip_spawn = true;
        }
        else if (is_undefined(_ap_id) && !is_undefined(_item_id))
        {
            // ap_id not in the AP location map at
            if (string_pos(STR_HEART, _item_id)
            ||  string_pos(STR_MAGIC, _item_id)
            ||  string_pos(STR_KEY,   _item_id)
            ||  string_pos(STR_1UP,   _item_id) )
            {
                if (item_acquired(_item_id)) _skip_spawn = true;
            }
        }
    }
    else
    {
        _skip_spawn = item_acquired(_item_id);
    }
    if (_skip_spawn)
    {
        var _ap_id_dbg = global.AP_location_map[?_dk_spawn];
        if (is_undefined(_ap_id_dbg) && !is_undefined(_item_id))
            _ap_id_dbg = global.AP_location_map[?_item_id];
        show_debug_message("AP_SKIP: dk=" + string(_dk_spawn) + " item=" + string(_item_id)
            + " ap_id=" + string(_ap_id_dbg)
            + " in_checked=" + string(!is_undefined(_ap_id_dbg) && ds_list_find_index(global.ap_checked_ids, _ap_id_dbg) != -1)
            + " acquired=" + string(item_acquired(_item_id)));
    }
    if (!_skip_spawn)
    {
        var _ap_replace_obj = noone;
        var _ap_replace_type = "";
        var _new_inst = noone;
        
        with(GameObject_create(_xl,_yt, _obj,_ver, _dk_spawn))
        {
            vspd = 1;
            if(!is_undefined(_item_id))
            {
                ITEM_ID = _item_id;
                SPAWN_DATAKEY = _dk_spawn;
                // AP: store spawn position for stable coord
                AP_spawn_x = _xl;
                AP_spawn_y = _yt;
                _new_inst = id;
                show_debug_message("go_spawn_priorities(). Item `"+object_get_name(object_index)+"` spawned. ITEM_ID: "+ITEM_ID+", _item_id: "+_item_id+", _dk_spawn: "+string(_dk_spawn));
                // AP: log the spawn position and computed
                var _coord_key_dbg = _dk_spawn + "_" + hex_str(AP_spawn_x) + "_" + hex_str(AP_spawn_y);
                var _has_entry = "NO";
                if (!is_undefined(global.AP_location_map[?_coord_key_dbg])) _has_entry = "YES";
                show_debug_message("AP_SPAWN_DEBUG: " + _coord_key_dbg + " has_entry=" + _has_entry + " map_size=" + string(ds_map_size(global.AP_location_map)));
                
                // AP: check scouted data for correct object
                if (global.AP_connected && variable_global_exists("ap_scouted_item_types"))
                {
                    var _ap_id = global.AP_location_map[?_dk_spawn];
                    show_debug_message("AP_DEBUG: _dk_spawn=" + string(_dk_spawn) + " -> _ap_id=" + string(_ap_id));
                    if (!is_undefined(_ap_id))
                    {
                        var _scouted_type = global.ap_scouted_item_types[?_ap_id];
                        if (!is_undefined(_scouted_type) && _scouted_type != "" && _scouted_type != ITEM_TYPE)
                        {
                            var _new_obj = g.dm_ITEM[?_scouted_type+STR_Object];
                            // Fallback: types w/o their own object entry
                            if (is_undefined(_new_obj) || _new_obj == noone)
                            {
                                if (Rando_is_spell(_scouted_type))
                                    _new_obj = g.dm_ITEM[?STR_SPELL+STR_Object]; // ItmS0
                                else if (string_pos(STR_KEY, _scouted_type) == 1)
                                    _new_obj = ItmD0; // Key — shows palace numeral via Item_draw
                                else if (_scouted_type == STR_STABDOWN || _scouted_type == STR_STABUP)
                                    _new_obj = ItmA7; // skill icon
                                else
                                    _new_obj = ItmF0; // Generic item holder
                            }
                            if (!is_undefined(_new_obj) && _new_obj != noone)
                            {
                                _ap_replace_obj = _new_obj;
                                _ap_replace_type = _scouted_type;
                            }
                        }
                        else if (is_undefined(_scouted_type) || _scouted_type == "")
                        {
                            // Cross-world item: flag for replacement with AP
                            var _scout_flags = global.ap_scouted_flags[?_ap_id];
                            ap_cross_world = true;
                            ap_cross_loc_id = _ap_id;
                            if (is_undefined(_scout_flags)) _scout_flags = 0;
                            ap_cross_flags = _scout_flags;
                            show_debug_message("AP_OVERRIDE: cross-world item at loc " + string(_ap_id) + ", flags=" + string(_scout_flags));
                        }
                    }
                }
            }
        }
        
        // Replace instance with srv-correct object if needed
        if (_ap_replace_obj != noone && _new_inst != noone)
        {
            instance_destroy(_new_inst);
            with(GameObject_create(_xl, _yt, _ap_replace_obj, 1, _dk_spawn))
            {
                if (!is_undefined(_item_id))
                {
                    ITEM_ID = _item_id;
                    SPAWN_DATAKEY = _dk_spawn;
                    // AP: store spawn position for stable coord
                    AP_spawn_x = _xl;
                    AP_spawn_y = _yt;
                    ITEM_TYPE = _ap_replace_type;
                    vspd = 1;
                    show_debug_message("AP_OVERRIDE: replaced with " + object_get_name(object_index) + " for type " + _ap_replace_type);
                }
            }
        }
        else if (_ap_replace_type != "" && _new_inst != noone)
        {
            // Object unchanged but type differs — just
            with (_new_inst)
            {
                ITEM_TYPE = _ap_replace_type;
                show_debug_message("AP_OVERRIDE: updated type to " + _ap_replace_type + " on " + object_get_name(object_index));
            }
        }
        
        // AP: replace cross-world items with dedicated AP
        if (_new_inst != noone && variable_instance_exists(_new_inst, "ap_cross_world"))
        {
            with (_new_inst)
            {
                if (ap_cross_world)
                {
                    // Pick the class-specific AP item object; each
                    var _ap_obj = obj_ap_item_filler;
                    // AP flags are a bitmask (prog=0b01, useful=0b10)
                    if      (ap_cross_flags & 1) { _ap_obj = obj_ap_item_prog;   }
                    else if (ap_cross_flags & 2) { _ap_obj = obj_ap_item_useful; }

                    var _loc_id = ap_cross_loc_id;
                    var _dk = SPAWN_DATAKEY;
                    // Spawn at the ORIGINAL left/top spawn
                    var _sx = AP_spawn_x;
                    var _sy = AP_spawn_y;
                    instance_destroy(id);
                    with (GameObject_create(_sx, _sy, _ap_obj, 1, _dk))
                    {
                        vspd          = 1;              // start falling (as native item spawns do)
                        ITEM_TYPE     = STR_PBAG;       // stab-able + no-bounce landing
                        SPAWN_DATAKEY = _dk;
                        AP_spawn_x    = _sx;
                        AP_spawn_y    = _sy;
                        ap_loc_id     = _loc_id;
                        // GameObject_create's Item branch clobbered sprite_index to
                        GO_sprite_init(object_get_sprite(object_index));
                        show_debug_message("AP_OVERRIDE: spawned managed " + object_get_name(object_index) + " for loc " + string(_loc_id));
                    }
                }
            }
        }
        
        //if (_SCENE_USED!=g.rm_name) sdm("SceneRando Item-E. _SCENE_USED '"+_SCENE_USED+"', g.rm_name '"+g.rm_name+"', _dk_spawn '"+_dk_spawn+"', _obj_name '"+_obj_name+"', _item_id '"+_item_id+"', _item_type '"+_item_type+"'");
    }
}


















//  -------------------------------------------------------------------------
//  -------------------------------------------------------------------------
//  -------------------------------------------------------------------------
//  -------------------------------------------------------------------------
//  -------------------------------------------------------------------------

//  ---------------------  PRIO GOB1&2  -------------------------
for(_i=0; _i<_RM_SPAWN_COUNT_PRIO; _i++)
{
    _dk_spawn = g.dg_spawn_prio[#_i,0];
    
    //if(!g.dg_spawn_prio[#_i,$E]) // $E: spawn permission
    if(!val(g.dm_spawn[?_dk_spawn+STR_Spawn_Permission]))
    {   // already used/opened/defeated..
        continue;//_i
    }
    
    //if (rm_get_encounter_types(g.rm_name)){ _str  = "_dk_spawn: "+_dk_spawn;
    //_str += "val(g.dm_spawn[?_dk_spawn+STR_Enc_Strong]): "+string(val(g.dm_spawn[?_dk_spawn+STR_Enc_Strong]));
    //_str += ", g.encounter_type: $"+hex_str(g.encounter_type)+", g.ENC_STRG: "+string(g.ENC_STRG);
    //sdm(""); sdm(_str); }
    
    if (rm_get_encounter_types(_SCENE_USED) 
    &&  sign(g.encounter_type&g.ENC_STRG) != sign(val(g.dm_spawn[?_dk_spawn+STR_Strong+STR_Encounter])) )
    {
        continue;//_i
    }
    
    
    _obj = g.dg_spawn_prio[#_i,1];
    _ver = g.dg_spawn_prio[#_i,3];
    _xl  = g.dg_spawn_prio[#_i,4];
    _yt  = g.dg_spawn_prio[#_i,6];
    
    
    if (is_ancestor_(_obj,Item,PushA))
    {
        continue;//_i
    }
    
    // if has been defeated and respawn type is NEVER
    if (update_go_spawn_1d(_obj,_ver, _dk_spawn))
    {
        continue;//_i
    }
    
    
    
    
    with(GameObject_create(_xl,_yt, _obj,_ver, _dk_spawn))
    {
        // ------------------------------------------
    }
    
    
    
    if(!is_undefined(g.dm_spawn[?_dk_spawn+STR_Spawn_Permission]))
    {                g.dm_spawn[?_dk_spawn+STR_Spawn_Permission] = 0;  }
}









_obj      = PushA;
_obj_name = object_get_name(_obj);
_count = val(g.dm_spawn[?_obj_name+STR_Count]);
for(_i=1; _i<=_count; _i++)
{
    _datakey1 = _obj_name + hex_str(_i);
    _dk_spawn = g.dm_spawn[?_datakey1+STR_Spawn+STR_Datakey];
    if(!is_undefined(_dk_spawn))
    {
        if(!val(g.dm_spawn[?_dk_spawn+STR_Spawn_Permission]))
        {   // already used/opened/defeated..
            continue;//_i
        }
        
        _qual = false;
        _scene_name = val(g.dm_spawn[?_datakey1+STR_Rm+STR_Name]);
        _val = f.dm_quests[?_dk_spawn+STR_Rm];
        if (_SCENE_USED==_scene_name)
        {
            if (is_undefined(_val) 
            ||  _SCENE_USED==_val )
            {
                _qual = true;
            }
        }
        else
        {
            if(!is_undefined(_val) 
            &&  _SCENE_USED==_val )
            {
                _qual = true;
            }
        }
        
        
        if (_qual)
        {
            _xl  = val(g.dm_spawn[? _dk_spawn+"_x"]);
            _xl  = val(f.dm_quests[?_dk_spawn+"_XL"], _xl);
            _xl  = (_xl>>3)<<3;
            
            _yt  = val(g.dm_spawn[? _dk_spawn+"_y"]);
            _yt  = val(f.dm_quests[?_dk_spawn+"_YT"], _yt);
            
            _ver = val(g.dm_spawn[? _dk_spawn+STR_Version],1);
            
            with(GameObject_create(_xl,_yt, _obj,_ver, _dk_spawn))
            {
                // ------------------------------------------
            }
            
            
            
            if(!is_undefined(g.dm_spawn[?_dk_spawn+STR_Spawn_Permission]))
            {                g.dm_spawn[?_dk_spawn+STR_Spawn_Permission] = 0;  }
        }
    }
}













// FAIRY ENCOUNTER -------------------------------------------------------
if (g.encounter_type&g.ENC_FARY)
{
    _xl = g.rm_w_ - 4;
    _yt = g.rm_row0<<3;
    _yt = get_ground_y(g.rm_w_,_yt, 1, (g.rm_row0+$12)<<3);
    
    with(GameObject_create(_xl,_yt, ReFaA,1))
    {
        set_xy(id, g.rm_w_,y);
    }
}













//  ------------  Platforms  ---------------------------
                                             _count=1;
_dk_spawn = _SCENE_USED+STR_Platform+hex_str(_count++);
while(!is_undefined(g.dm_spawn[?_dk_spawn+STR_obj_idx]))
{
    _obj = g.dm_spawn[?_dk_spawn+STR_obj_idx];
    _ver = g.dm_spawn[?_dk_spawn+STR_version];
    _xl  = g.dm_spawn[?_dk_spawn+"_x"];
    _yt  = g.dm_spawn[?_dk_spawn+"_y"];
    
    with(GameObject_create(_xl,_yt, _obj,_ver, _dk_spawn))
    {
        // ------------------------------------------
    }
    
    _dk_spawn = _SCENE_USED+STR_Platform+hex_str(_count++);
}












/*
//  ------------  Challenge  ---------------------------
_count2=1;
_dk_spawn2 = g.rm_name+STR_Challenge+hex_str(_count2++);
_obj2      = g.dm_spawn[?_dk_spawn2+STR_obj_idx];
while(!is_undefined(_obj2))
{
    _ver = g.dm_spawn[?_dk_spawn2+STR_version];
    _xl  = g.dm_spawn[?_dk_spawn2+"_x"];
    _yt  = g.dm_spawn[?_dk_spawn2+"_y"];
    
    _dk_spawn = _dk_spawn2;
    _obj = _obj2;
    if (global.SceneRando_enabled 
    &&  _SCENE_USED!=g.rm_name )
    {   // Currently, this assumes each scene only has 1 Challenge object which is the same challenge requirements
        _count1=1;
        _dk_spawn1 = _SCENE_USED+STR_Challenge+hex_str(_count1++);
        _obj1      = g.dm_spawn[?_dk_spawn1+STR_obj_idx];
        while(!is_undefined(_obj1))
        {
            if (is_ancestor(_obj1,_obj2))
            {
                _dk_spawn = _dk_spawn1;
                _obj = _obj1;
                _ver = val(g.dm_spawn[?_dk_spawn1+STR_version],_ver);
                _xl  = val(g.dm_spawn[?_dk_spawn1+"_x"],_xl);
                _yt  = val(g.dm_spawn[?_dk_spawn1+"_y"],_yt);
                break;//while(!is_undefined(_obj1))
            }
            
            _dk_spawn1 = g.rm_name+STR_Challenge+hex_str(_count1++);
            _obj1      = g.dm_spawn[?_dk_spawn1+STR_obj_idx];
        }
    }
    
    with(GameObject_create(_xl,_yt, _obj,_ver, _dk_spawn))
    {
        // ------------------------------------------
    }
    
    _dk_spawn2 = g.rm_name+STR_Challenge+hex_str(_count2++);
    _obj2      = g.dm_spawn[?_dk_spawn2+STR_obj_idx];
}
*/




