/// GOB_update_data_defeated(GOB instance id)


with(argument0)
{
    var          _DK  = get_defeated_dk(); // STR_File+STR_Quest+hex_str(f.quest_num)+STR_Defeated+"_";
    
    var          _dk  = _DK+object_get_name(object_index)+STR_Version+hex_str(ver);
    
    f.dm_quests[?_dk] = val(f.dm_quests[?_dk]) + 1;
    
                 _dk += g.rm_name;
    f.dm_quests[?_dk] = val(f.dm_quests[?_dk]) + 1;
    
    
    
    if (is_undefined(dk_spawn)) exit; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
                 _dk += STR_Spawn_Idx + string_copy(dk_spawn, string_length(dk_spawn)-2, 2);
    f.dm_quests[?_dk] = val(f.dm_quests[?_dk]) + 1;
    
    
                 _dk  = _DK+dk_spawn;
    f.dm_quests[?_dk] = val(f.dm_quests[?_dk]) + 1;

    if (object_index == Thunderbird01 && global.AP_connected
    &&  variable_global_exists("ap_slot_data") && !is_undefined(global.ap_slot_data))
    {
        var _boss_option = ds_map_find_value(global.ap_slot_data, "boss_item_locations");
        if (!is_undefined(_boss_option) && real(_boss_option)
        &&  variable_global_exists("ap_boss_item_location_ids")
        && !is_undefined(global.ap_boss_item_location_ids))
        {
            var _boss_id = ds_map_find_value(global.ap_boss_item_location_ids, "7");
            if (!is_undefined(_boss_id))
            {
                if (!variable_global_exists("AP_location_map"))
                    global.AP_location_map = ds_map_create();
                global.AP_location_map[?"_AP_BOSS_ITEM_7"] = real(_boss_id);
                global.AP_location_map[?"_AP_BOSS_ITEM_7_desc"] = "Great Palace: Thunderbird Boss Item";
                ap_check_location("_AP_BOSS_ITEM_7", undefined, g.rm_name, x, y);
            }
        }
    }
}




