/// Rando_set_data_1a(loc num, item id)
show_debug_message("RSD1A_ENTER loc=$" + hex_str(argument0) + " item=" + string(argument1));


var _i, _a, _idx, _val, _num, _count;
var _obj, _ver;
var _datakey, _pos;
var _loc_num, _loc_id;

                               _a=0;
var _LOC_NUM =        argument[_a++];
var _ITEM_ID = string(argument[_a++]);

var                                      _ITEM_TYPE=_ITEM_ID;
     if (string_pos(STR_HEART,_ITEM_ID)) _ITEM_TYPE=STR_HEART;
else if (string_pos(STR_MAGIC,_ITEM_ID)) _ITEM_TYPE=STR_MAGIC;
else if (string_pos(STR_1UP,  _ITEM_ID)) _ITEM_TYPE=STR_1UP;
else if (string_pos(STR_PBAG, _ITEM_ID)) _ITEM_TYPE=STR_PBAG;
else if (string_pos(STR_KEY,  _ITEM_ID)) _ITEM_TYPE=STR_KEY;


var _is_already_placed=false;

// AP: Build location lookup map (used regardless
var _desc = dm_LOCATIONS[?hex_str(_LOC_NUM) + STR_Description];
var _SPAWN_DATAKEY = dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Spawn+STR_Datakey];
// AP: fallback — if dm_LOCATIONS didn't find
if (is_undefined(_SPAWN_DATAKEY) || _SPAWN_DATAKEY == "" || _SPAWN_DATAKEY == "undefined")
{
    // Spell locations: key the AP map on the
    if (Rando_is_spell(_ITEM_ID))
    {
        // Look up the physical Wise Man NPC dk
        var _sp_rm = val(dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Rm+STR_Name], "");
        if (_sp_rm != "")
            _SPAWN_DATAKEY = g.dm_spawn[?"_Wise"+"_Man"+STR_Spawn+STR_Datakey+_sp_rm];
        // Fallback to vanilla spell→NPC mapping if room
        if (is_undefined(_SPAWN_DATAKEY) || _SPAWN_DATAKEY == "" || _SPAWN_DATAKEY == "undefined")
            _SPAWN_DATAKEY = g.dm_spawn[?STR_Spell+STR_Spawn+STR_Datakey+_ITEM_ID];
        show_debug_message("AP_DK_FALLBACK: spell loc=$" + hex_str(_LOC_NUM) + " rm='" + _sp_rm + "' dk='" + string(_SPAWN_DATAKEY) + "'");
    }
    // Regular items: search room's PRIO spawns matching
    if (is_undefined(_SPAWN_DATAKEY) || _SPAWN_DATAKEY == "" || _SPAWN_DATAKEY == "undefined")
    {
        var _rm_name2 = dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Rm+STR_Name];
        var _itype2   = dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Item+STR_Base+STR_Key];
        var _inum2    = dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Rm+STR_Item+STR_Base+STR_Key+STR_Num];
        if (!is_undefined(_rm_name2) && !is_undefined(_itype2) && !is_undefined(_inum2))
        {
            var _pcount = val(g.dm_spawn[?get_spawn_datakey(_rm_name2, STR_PRIO, -1)]);
            var _pmatch = 0;
            for (var _pj = 0; _pj < _pcount; _pj++)
            {
                var _try_dk = get_spawn_datakey(_rm_name2, STR_PRIO, _pj);
                // Quest-aware ordinal, same as the primary matcher
                var _qq2 = g.dm_spawn[?_try_dk+STR_Qualified+STR_Quest+STR_Nums];
                if (!is_undefined(_qq2) && is_string(_qq2) && !string_pos(hex_str(QUEST_NUM), _qq2))
                    continue;//_pj
                var _obj_at = val(g.dm_spawn[?_try_dk + STR_obj_idx], noone);
                if (_obj_at)
                {
                    var _type_at = g.dm_ITEM[?object_get_name(_obj_at) + STR_Item + STR_Type];
                    if (!is_undefined(_type_at) && _type_at == _itype2)
                    {
                        _pmatch++;
                        if (_pmatch == _inum2)
                        {
                            _SPAWN_DATAKEY = _try_dk;
                            show_debug_message("AP_DK_FALLBACK: loc=$" + hex_str(_LOC_NUM) + " dk=" + string(_SPAWN_DATAKEY));
                            break;
                        }
                    }
                }
            }
        }
    }
}
var _ap_id = 0;

// New AP slots provide the exact set of locations created for this seed.
// Do not manufacture mappings for catalog entries that are absent.
if (variable_global_exists("ap_created_manifest_ready")
&&  global.ap_created_manifest_ready)
{
    var _manifest_ap_id = ds_map_find_value(global.ap_created_location_indices, _LOC_NUM);
    if (is_undefined(_manifest_ap_id)) _ap_id = -1;
    else _ap_id = real(_manifest_ap_id);
}

// Diagnostic: show what we're looking up
show_debug_message("RSD1A loc=$" + hex_str(_LOC_NUM) + " desc=" + string(_desc) + " item=" + string(_ITEM_ID) + " spawn_dk=" + string(_SPAWN_DATAKEY));

if (_ap_id == 0 && variable_global_exists("ap_location_name_to_id") && !is_undefined(global.ap_location_name_to_id) && !is_undefined(_desc) && _desc != "")
{
    var _ap_id_raw = ds_map_find_value(global.ap_location_name_to_id, _desc);
    if (!is_undefined(_ap_id_raw))
    {
        _ap_id = real(_ap_id_raw);
        show_debug_message("AP_MATCH: loc=" + string(_LOC_NUM) + " desc='" + _desc + "' -> ap_id=" + string(_ap_id));
    }
    else
    {
        show_debug_message("AP_NO_MATCH: loc=" + string(_LOC_NUM) + " desc='" + _desc + "' not found in location_name_to_id");
    }
}

if (_ap_id == 0)
{
    // Fallback: calculate from location number (for non-AP
    _ap_id = 387642575169 + (_LOC_NUM - 1);
}

if (is_undefined(_ap_id))
{
    // Fallback: calculate from location number (for non-AP
    _ap_id = 387642575169 + (_LOC_NUM - 1);
}

if (_ap_id > 0 && !is_undefined(_desc) && is_string(_desc) && _desc != "" && !is_undefined(_SPAWN_DATAKEY))
{
    if (!variable_global_exists("AP_location_map"))
        global.AP_location_map = ds_map_create();
    global.AP_location_map[?_SPAWN_DATAKEY] = _ap_id;
    global.AP_location_map[?_SPAWN_DATAKEY + "_desc"] = _desc;
    if (!is_undefined(_ap_id))
    {
        var _ap_id_str1 = string(_ap_id);
        if (_ap_id_str1 != "" && _ap_id_str1 != "0" && _ap_id_str1 != "undefined")
        {
            global.AP_location_map[?_ap_id_str1 + "_spawn"] = _SPAWN_DATAKEY;
            global.AP_location_map[?_ap_id_str1 + "_desc"] = _desc;
        }
    }
    // AP: also store coord key (roomname_$x_$y) —
    if (!is_undefined(_SPAWN_DATAKEY) && _SPAWN_DATAKEY != "")
    {
        var _coord_x1 = val(g.dm_spawn[?_SPAWN_DATAKEY + "_x"], 0);
        var _coord_y1 = val(g.dm_spawn[?_SPAWN_DATAKEY + "_y"], 0);
        // P-Bags/Jars store _x/_y under _ITEM_ID
        if (_coord_x1 <= 0 || _coord_y1 <= 0)
        {
            _coord_x1 = val(g.dm_spawn[?_ITEM_ID + "_x"], 0);
            _coord_y1 = val(g.dm_spawn[?_ITEM_ID + "_y"], 0);
        }
        if (_coord_x1 > 0 && _coord_y1 > 0)
        {
            var _coord_key1 = _SPAWN_DATAKEY + "_" + hex_str(_coord_x1) + "_" + hex_str(_coord_y1);
            if (!is_undefined(_ap_id) && _ap_id > 0)
                global.AP_location_map[?_coord_key1] = _ap_id;
        }
    }
    global.AP_location_map[?_ITEM_ID] = _ap_id;
    show_debug_message("AP_MAP: spawn=" + string(_SPAWN_DATAKEY) + " -> ap_id=" + string(_ap_id) + " desc='" + _desc + "'");
}
else
{
    if (_LOC_NUM <= 30)
    {
        show_debug_message("AP_MAP_SKIP: loc=$" + hex_str(_LOC_NUM) + " desc=" + string(_desc) + " item=" + string(_ITEM_ID) + " spawn_dk=" + string(_SPAWN_DATAKEY) + " desc_undef=" + string(is_undefined(_desc)) + " desc_str=" + string(is_string(_desc)) + " spawn_undef=" + string(is_undefined(_SPAWN_DATAKEY)));
    }
}

if (_ap_id > 0 && !is_undefined(_desc) && is_string(_desc) && _desc != "" && !is_undefined(_ITEM_ID))
{
    if (!variable_global_exists("AP_location_map"))
        global.AP_location_map = ds_map_create();
    global.AP_location_map[?_ITEM_ID] = _ap_id;
    global.AP_location_map[?_ITEM_ID + "_desc"] = _desc;
    // Also store a coordinate-based key (room_x_y) —
    if (!is_undefined(_SPAWN_DATAKEY) && _SPAWN_DATAKEY != "")
    {
        var _coord_x = val(g.dm_spawn[?_SPAWN_DATAKEY + "_x"], 0);
        var _coord_y = val(g.dm_spawn[?_SPAWN_DATAKEY + "_y"], 0);
        if (_coord_x > 0 && _coord_y > 0)
        {
            var _coord_key = _SPAWN_DATAKEY;  // simplified: just use spawn datakey as coord
            // For now, skip the full coord lookup
        }
    }
    // Only write _ap_id-based keys when we have a
    if (!is_undefined(_ap_id))
    {
        var _ap_id_str2 = string(_ap_id);
        if (_ap_id_str2 != "" && _ap_id_str2 != "0" && _ap_id_str2 != "undefined")
        {
            global.AP_location_map[?_ap_id_str2 + "_desc"] = _desc;
        }
    }
    show_debug_message("AP_MAP: (no spawn dk) item=" + string(_ITEM_ID) + " -> ap_id=" + string(_ap_id) + " desc='" + _desc + "'");
}

var _IS_SPELL = Rando_is_spell(_ITEM_ID);
// Save the early _SPAWN_DATAKEY before line
var _early_spell_dk = _SPAWN_DATAKEY;
if (_IS_SPELL)
{
    if (ds_list_find_index(dl_spells_placed,_ITEM_ID)==-1)
    {   ds_list_add(       dl_spells_placed,_ITEM_ID);  }
    else _is_already_placed=true;
}
else if (string_pos(STR_KEY,_ITEM_ID))
{
    if (ds_list_find_index(dl_keys_placed,_ITEM_ID)==-1)
    {   ds_list_add(       dl_keys_placed,_ITEM_ID);  }
    else _is_already_placed=true;
}
else
{
    if (ds_list_find_index(dl_items_placed,_ITEM_ID)==-1)
    {   ds_list_add(       dl_items_placed,_ITEM_ID);  }
    else _is_already_placed=true;
    
    if(!_is_already_placed)
    {
        switch(_ITEM_ID)
        {
            case STR_FLUTE:{
            FLUTE_LOC_NUM=_LOC_NUM;
            break;}//case STR_FLUTE
            
            case STR_ALLKEY:{
            if (CONTROL_ALLKEY==1) ALLKEY_LOC_NUM=_LOC_NUM;
            //sdm("ALLKEY location num: $"+hex_str(_LOC_NUM));
            break;}//case STR_ALLKEY
        }//switch(_ITEM_ID)
    }
}

if (_is_already_placed)
{
    sdm("*** "+_ITEM_ID+" HAS ALREADY BEEN PLACED!! ***");
    return false;
}





if (_ITEM_TYPE==STR_HEART)
{
    if (ds_list_find_index(dl_placed_containers_hp,_ITEM_ID)==-1)
    {   ds_list_add(       dl_placed_containers_hp,_ITEM_ID);  }
}

if (_ITEM_TYPE==STR_MAGIC)
{
    if (ds_list_find_index(dl_placed_containers_mp,_ITEM_ID)==-1)
    {   ds_list_add(       dl_placed_containers_mp,_ITEM_ID);  }
}








var _DATAKEY = STR_Location+hex_str(_LOC_NUM);


var _SPAWN_DATAKEY = dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Spawn+STR_Datakey];
var _RM_NAME       = val(dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Rm+STR_Name],       "undefined");


dm_save_data[?      _DATAKEY+STR_Spawn+STR_Datakey]          = _SPAWN_DATAKEY;
dm_save_data[?      _DATAKEY+STR_Item+STR_ID+STR_Randomized] = _ITEM_ID;
dm_save_data[?      _DATAKEY+STR_Description]                = _desc;
if (!is_undefined(_SPAWN_DATAKEY))
    dm_save_data[?_SPAWN_DATAKEY+STR_Item+STR_ID+STR_Randomized] = _ITEM_ID;
dm_save_data[?_ITEM_ID+STR_Location+STR_Num +STR_Randomized] = _LOC_NUM;
// AP: store coordinate key (roomname_$x_$y) for stable
if (!is_undefined(_SPAWN_DATAKEY) && _SPAWN_DATAKEY != "")
{
    var _coord_x = val(g.dm_spawn[?_SPAWN_DATAKEY + "_x"], 0);
    var _coord_y = val(g.dm_spawn[?_SPAWN_DATAKEY + "_y"], 0);
    // P-Bags/Jars store _x/_y under _ITEM_ID
    if (_coord_x <= 0 || _coord_y <= 0)
    {
        _coord_x = val(g.dm_spawn[?_ITEM_ID + "_x"], 0);
        _coord_y = val(g.dm_spawn[?_ITEM_ID + "_y"], 0);
    }
    if (_coord_x > 0 && _coord_y > 0)
    {
        var _coord_key = _SPAWN_DATAKEY + "_" + hex_str(_coord_x) + "_" + hex_str(_coord_y);
        dm_save_data[?_coord_key + STR_Item+STR_ID+STR_Randomized] = _ITEM_ID;
        // Also add to AP map directly (it's available
        if (variable_global_exists("AP_location_map") && !is_undefined(_ap_id) && _ap_id > 0)
        {
            if (!is_undefined(_desc) && is_string(_desc) && _desc != "")
                global.AP_location_map[?_coord_key] = _ap_id;
        }
    }
}








if (_IS_SPELL)
{
    // AP: track the JUMP spell's true placement
    if (_ITEM_ID == STR_JUMP) JUMP_LOC_NUM = _LOC_NUM;

    var _TOWN_NAME = val(g.dm_rm[?_RM_NAME+STR_Town+STR_Name]);
    if (ds_list_find_index(dl_TOWN_NAMES,_TOWN_NAME)!=-1)
    {
        dm_save_data[?_DATAKEY+STR_Spell]         = val(dm_save_data[?_TOWN_NAME+STR_Spell], "undefined");
        dm_save_data[?_ITEM_ID+STR_Location]      = _TOWN_NAME;

        dm_save_data[?_ITEM_ID+STR_Town+STR_Name] = _TOWN_NAME;
        dm_save_data[?_DATAKEY+STR_Town+STR_Name] = _TOWN_NAME;
    }

    // AP: correct the AP_location_map to use the
    if (variable_global_exists("AP_location_map") && !is_undefined(_ap_id) && _ap_id > 0)
    {
        // Look up the physical NPC dk by room
        var _phys_dk = val(g.dm_spawn[?"_Wise"+"_Man"+STR_Spawn+STR_Datakey+_RM_NAME], "");
        if (_phys_dk != "" && !is_undefined(_phys_dk))
        {
            // Remove the wrong key written in the early
            if (!is_undefined(_early_spell_dk) && _early_spell_dk != "" && _early_spell_dk != _phys_dk)
                ds_map_delete(global.AP_location_map, _early_spell_dk);
            // Write the correct physical dk
            global.AP_location_map[?_phys_dk] = _ap_id;
            global.AP_location_map[?_phys_dk + "_desc"] = _desc;
            var _ap_str = string(_ap_id);
            if (_ap_str != "0") global.AP_location_map[?_ap_str + "_spawn"] = _phys_dk;
            show_debug_message("AP_WISE_FIX: loc=$" + hex_str(_LOC_NUM) + " town='" + string(_TOWN_NAME) + "' dk='" + _phys_dk + "' ap_id=" + string(_ap_id));
        }
        else
        {
            show_debug_message("AP_WISE_FIX: WARNING loc=$" + hex_str(_LOC_NUM) + " town='" + string(_TOWN_NAME) + "' could not find physical NPC dk, using '" + string(_SPAWN_DATAKEY) + "'");
        }
    }

    sdm(""); dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = "";
    debug_str = "SPELL  "+_ITEM_ID+"  PLACED!";
    sdm(debug_str); dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = debug_str;
    sdm(""); dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = "";
    return true;
}




placement_num++;




var _OBJ_NAME = val(g.dm_ITEM[?_ITEM_TYPE+STR_Object+STR_Name], "NONE");
var _OBJ      = val(g.dm_ITEM[?_ITEM_TYPE+STR_Object], noone);
var _ITEM_BIT = val(g.dm_ITEM[?_ITEM_TYPE+STR_Bit]);







var _CAN_PRINT_DEBUG = _ITEM_TYPE==STR_KEY || KeyLocations_WILL_RANDOMIZE;
if (DEBUG)
{
    debug_str  = "$"+hex_str(placement_num)+". ";
    debug_str += "loc_num $"+hex_str(_LOC_NUM)+": ";
    debug_str += "#(";
    debug_str += _ITEM_ID;
    debug_str += ")#";
    debug_str += string_repeat(" ", max(0,$A-string_length(_ITEM_ID)));
    debug_str += ".  ";
    debug_str += _RM_NAME;
    debug_str += " - "+val(dm_LOCATIONS[?hex_str(_LOC_NUM)+STR_Description], "location?");
    if (_CAN_PRINT_DEBUG) sdm(debug_str);
    dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = debug_str;
}




if (global.RandoHints_VER==2 
&&  ds_list_find_index(dl_hint_items,_ITEM_ID)!=-1 )
{
    if(!KeyLocations_WILL_RANDOMIZE 
    ||  _ITEM_ID!=STR_ALLKEY )
    {
        if (QUEST_NUM==2 
        ||  _ITEM_ID!=STR_MASK )
        {
            if ( ItemLocations_ZELDA_HINT==ZELDA_HINT_OPTIONS.NONE 
            ||   ItemLocations_ZELDA_HINT==ZELDA_HINT_OPTIONS.JUMP 
            ||  (ItemLocations_ZELDA_HINT==ZELDA_HINT_OPTIONS.FLUTE  && _ITEM_ID!=STR_FLUTE) 
            ||  (ItemLocations_ZELDA_HINT==ZELDA_HINT_OPTIONS.ALLKEY && _ITEM_ID!=STR_ALLKEY) )
            {
                var _HINT_LOCATION_COUNT = ds_list_size(dl_hint_loc_nums_shuffled);
                if (_HINT_LOCATION_COUNT)
                {
                    var _hint_num, _hint_scene, _scene_hint_num, _normal_dialogue_dk, _hint_dialogue, _hint_was_set;
                    //var _ITEM_LOC_SPAWN_DK = dm_save_data[?STR_Location+hex_str(_LOC_NUM)+STR_Spawn+STR_Datakey];
                    _hint_was_set = false;
                    
                    for(_i=0; _i<_HINT_LOCATION_COUNT; _i++)
                    {
                        _hint_num = dl_hint_loc_nums_shuffled[|_i];
                        _hint_scene         = g.dm_RandoHints[?hex_str(_hint_num)+STR_Rm+STR_Name];
                        _scene_hint_num     = g.dm_RandoHints[?hex_str(_hint_num)+STR_Scene+STR_Hint+STR_Num];
                        _normal_dialogue_dk = g.dm_RandoHints[?hex_str(_hint_num)+STR_Dialogue+STR_Datakey]; // datakey for NPC's normal(non-rando) dialogue
                        _hint_dialogue = dm_LOCATIONS[?hex_str(_LOC_NUM)+dk_ChosenHintDialogue];
                        if(!is_undefined(_hint_scene) 
                        && !is_undefined(_scene_hint_num) 
                        && !is_undefined(_normal_dialogue_dk) 
                        && !is_undefined(_hint_dialogue) )
                        {
                            // Need to remove `_ITEM_ID` from `dl_items_placed`, otherwise `Rando_is_qual_hint_location()` could lock the hint behind the `_ITEM_ID`
                            _idx = ds_list_find_index(dl_items_placed,_ITEM_ID);
                            if (_idx!=-1) ds_list_delete(dl_items_placed,_idx);
                            
                            if (Rando_is_qual_hint_location(_hint_scene, _scene_hint_num)) // if the player can reach this hint location with only the items placed so far
                            {
                                _pos = string_pos("&",_hint_dialogue); // "&": the indicator for where the item name should go
                                if (_pos)
                                {
                                    _val = string_upper(string_letters(_ITEM_ID));
                                    _hint_dialogue = string_delete(_hint_dialogue,_pos,1);
                                    _hint_dialogue = string_insert(_val,_hint_dialogue,_pos);
                                    //_hint_dialogue = string_replace(_hint_dialogue,_val,_pos);
                                }
                                
                                _count = val(dm_save_data[?STR_Rando+STR_Hint+STR_Count]) + 1;
                                dm_save_data[?STR_Rando+STR_Hint+STR_Count] = _count;
                                
                                dm_save_data[?STR_Rando+STR_Hint+hex_str(_count)+STR_Dialogue+STR_Datakey] = _normal_dialogue_dk;
                                dm_save_data[?STR_Rando+STR_Hint+hex_str(_count)+STR_Dialogue]             = _hint_dialogue;
                                dm_save_data[?STR_Rando+STR_Hint+hex_str(_count)+STR_Item]                 = _ITEM_ID;
                                dm_save_data[?STR_Rando+STR_Hint+_normal_dialogue_dk+STR_Hint+STR_Num]     = _count;
                                dm_save_data[?STR_Rando+STR_Hint+_normal_dialogue_dk]                      = _hint_dialogue;
                                
                                _hint_was_set = true;
                                ds_list_delete(dl_hint_loc_nums_shuffled,_i);
                                
                                debug_str  = _ITEM_ID+string_repeat(" ",string_length(STR_BRACELET)-string_length(_ITEM_ID));
                                debug_str += " hint dialogue '"+_hint_dialogue+"' set to datakey "+_normal_dialogue_dk+". Hint location id: "+_hint_scene+hex_str(_scene_hint_num);
                                show_debug_message(debug_str); dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = debug_str;
                                show_debug_message(""); dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = "";
                            }
                            
                            // Add `_ITEM_ID` back to `dl_items_placed`
                            if (ds_list_find_index(dl_items_placed,_ITEM_ID)==-1) ds_list_add(dl_items_placed,_ITEM_ID);
                            
                            if (_hint_was_set)
                            {
                                break;//_i
                            }
                        }
                    }
                    
                    /* If somehow there was no qualified hint location for the item, 
                    should an unqualified location be used?
                    It's possible the player could still reach the hint if they break logic.
                    */
                    if(!_hint_was_set)
                    {
                        show_debug_message("");
                        show_debug_message("!!! WARNING !!!  ["+_ITEM_ID+"]  DID NOT GET A HINT !!!");
                        show_debug_message("");
                    }
                }
            }
        }
    }
}




if (DEBUG && DEBUG_extra_line1)
{
    _count = ds_list_size(dl_items_placed)+ds_list_size(dl_keys_placed);
    if (_count 
    && !(_count&$3) )
    {
        if (_CAN_PRINT_DEBUG) sdm("");
        dm_debug_data[?STR_Data+'01'+hex_str(++debug_data_count)] = "";
    }
}








if (CONTROL_ALLKEY==2 
&&  ALLKEY_LOC_NUM 
&& !KeyLocations_WILL_RANDOMIZE 
&&  _ITEM_ID!=STR_ALLKEY 
&&  ds_list_find_index(dl_items_placed,STR_ALLKEY)==-1 )
{
    _loc_num = ALLKEY_LOC_NUM;
    _loc_id  = val(dm_LOCATIONS[?hex_str(_loc_num)+STR_Location+STR_ID], "undefined");
    if (Rando_is_qual_location(_loc_id) 
    &&  Rando_set_data_1a(_loc_num, STR_ALLKEY) )
    {
            _idx =    ds_list_find_index(dl_locations_remaining,_loc_num);
        if (_idx!=-1) ds_list_delete(    dl_locations_remaining,_idx);
    }
}



if (KeyLocations_WILL_RANDOMIZE 
&&  _ITEM_ID!=STR_ALLKEY 
&&  ds_list_find_index(dl_items_placed,STR_ALLKEY)==-1 )
{
    _loc_num = val(dm_LOCATIONS[?STR_ALLKEY+STR_Location+STR_Num]);
    _loc_id  = val(dm_LOCATIONS[?hex_str(_loc_num)+STR_Location+STR_ID], "undefined");
    if (Rando_is_qual_location(_loc_id)) Rando_set_data_1a(_loc_num, STR_ALLKEY);
}



if (KeyLocations_WILL_RANDOMIZE 
&& !FallingKey_item_placed 
&&  FallingKey_LOC_NUM!=_LOC_NUM 
&&  FallingKey_ITEM_ID!=_ITEM_ID )
{
    var _FallingKey_item_id = undefined;
    
    if (ItemLocations_INCLUDE_PBAG 
    &&  irandom(1) )
    {
        for(_i=ds_list_size(dl_ItemPool_C)-1; _i>=0; _i--)
        {
            if (ds_list_find_index(dl_PBAGS,dl_ItemPool_C[|_i])!=-1)
            {
                _FallingKey_item_id =       dl_ItemPool_C[|_i];
                break;//_i
            }
        }
    }
    
    if (is_undefined(_FallingKey_item_id) 
    &&  ds_list_size(dl_remaining_keys) )
    {   // *** dl_remaining_keys has already been shuffled
        _FallingKey_item_id = dl_remaining_keys[|0];
    }
    
    if (is_undefined(_FallingKey_item_id) 
    && !is_undefined( FallingKey_ITEM_ID) 
    &&  ds_list_size(      dl_remaining_keys) 
    &&  ds_list_find_index(dl_remaining_keys,FallingKey_ITEM_ID)!=-1  )
    {                _FallingKey_item_id =   FallingKey_ITEM_ID;  }
    
    
    if(!is_undefined(_FallingKey_item_id) 
    &&  Rando_is_qual_location(FallingKey_LOC_ID,  _FallingKey_item_id) 
    &&  Rando_set_data_1a(     FallingKey_LOC_NUM, _FallingKey_item_id) )
    {
        FallingKey_item_placed=true;
            _idx =    ds_list_find_index(dl_ItemPool_C,_FallingKey_item_id);
        if (_idx!=-1) ds_list_delete(    dl_ItemPool_C,_idx);
            _idx =    ds_list_find_index(dl_remaining_keys,_FallingKey_item_id);
        if (_idx!=-1) ds_list_delete(    dl_remaining_keys,_idx);
    }
}







if (ds_list_find_index(dl_ItemPool_A,_ITEM_ID)!=-1)
{
    ds_list_copy(dl_qualified_locations_old,dl_qualified_locations);
}








//if (global.RandoHints_VER==2






return true;




