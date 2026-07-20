/// update_Dialogue_1a()



switch(g.dialogue_source.object_index)
{
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_0:{
    if (g.dialogue_source.ver==3) // Mirror
    {   // B5AE
        //f.dm_quests[? hex_str(rm_get_town_idx())] |= 1;
        break;//case NPC_0
    }
    
    
    if (g.dialogue_source.ver==4) // Foutain
    {   // B5AE
        //f.items |= ITM_WATR;
        //f.dm_quests[?STR_Quest+STR_Spell+STR_FIRE] = 1;
        //var _TOWN_NAME = val(g.dm_town_data[?STR_Town_name+hex_str(g.town_num-1)], STR_Rauru);
        //f.dm_quests[?STR_Quest+_TOWN_NAME+'01'] |= 1;
        break;//case NPC_0
    }
    
    
    if (f.items&ITM_BOOK 
    &&  g.dialogue_source.HylianText_read )
    {
            _FONT = val(dm_dialogue[?g.dialogue_source.dialogue_datakey+'A'+STR_Font], global.dl_game_font[|global.game_font_idx]);
        if (_FONT==spr_Font_Hyrulian) dialogue_ver = 'B'; // Translated text
    }
    break;}//case NPC_0
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_4:{ // B57D. Healer, Saver
    if (g.gui_state==g.gui_state_DIALOGUE2) // in restore house
    {
        dialogue_ver = "B"; // In restore house dialogue.
    }
    else
    {   // B58C: JSR 9A50
        //scr_NPC_6a(g.dialogue_source);
        
        //if (ver==1  // v1: Heal Life
        //&& !irandom($1000) )
    }
    break;}//case NPC_4
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_5:{ // B560. Quest
    if (is_undefined(g.dialogue_source.dk_spawn))
    {
        break;//case NPC_5
    }
    
    if (quest_is_complete(val(g.dm_spawn[?g.dialogue_source.dk_spawn+STR_Quest+STR_ID], STR_undefined)))
    {
        if(!is_undefined(g.town_name))
        {
            f.dm_quests[?g.town_name+STR_Quest+STR_Complete] = true;
        }
        
        dialogue_ver = "B"; // alt dialogue
    }
    break;}//case NPC_5
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_6:{ // B4BF, B4D7. Skill Knight
    switch(g.dialogue_source.ver)
    {
        case 1:{
        // AP: resolve this town's Stab Down skill-check
        var _sk1_id = undefined;
        if (global.AP_connected && variable_global_exists("ap_location_name_to_id")
        &&  !is_undefined(g.town_name) && g.town_name != "")
        {
            var _sk1_desc = STR_Skill+STR_Location+g.town_name;
            _sk1_id = ds_map_find_value(global.ap_location_name_to_id, _sk1_desc);
        }
        if (!is_undefined(_sk1_id))
        {
            var _sk1_real = real(_sk1_id);
            // AP: never play the local acquisition. dialogue_ver
            dialogue_ver = "B";
            if (ds_list_find_index(global.ap_checked_ids, _sk1_real) == -1)
            {
                apclient_location_checks("[" + string(_sk1_real) + "]");
                show_debug_message("AP: Checked skill location " + _sk1_desc + " (" + string(_sk1_real) + ")");
                ds_list_add(global.ap_checked_ids, _sk1_real);
            }
        }
        else
        { // Vanilla / offline (or skills not
            if (f.skills&SKILL_THD) dialogue_ver = "B"; // already have skill dialogue
            f.skills |= SKILL_THD;
        }
        break;}//case 1

        case 2:{
        // AP: resolve this town's Stab Up skill-check
        var _sk2_id = undefined;
        if (global.AP_connected && variable_global_exists("ap_location_name_to_id")
        &&  !is_undefined(g.town_name) && g.town_name != "")
        {
            var _sk2_desc = STR_Skill+STR_Location+g.town_name;
            _sk2_id = ds_map_find_value(global.ap_location_name_to_id, _sk2_desc);
        }
        if (!is_undefined(_sk2_id))
        {
            var _sk2_real = real(_sk2_id);
            // AP: never play the local acquisition. dialogue_ver
            dialogue_ver = "B";
            if (ds_list_find_index(global.ap_checked_ids, _sk2_real) == -1)
            {
                apclient_location_checks("[" + string(_sk2_real) + "]");
                show_debug_message("AP: Checked skill location " + _sk2_desc + " (" + string(_sk2_real) + ")");
                ds_list_add(global.ap_checked_ids, _sk2_real);
            }
        }
        else
        { // Vanilla / offline (or skills not
            if (f.skills&SKILL_THU) dialogue_ver = "B"; // already have skill dialogue
            f.skills |= SKILL_THU;
        }
        break;}//case 2
    }//switch(g.dialogue_source.ver)
    break;}//case NPC_6
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_7:{ // B518. Spell Giver
    var _BIT = g.dialogue_source.give_spell;

    // AP: remap dialogue to reflect the AP-world
    var _ap_non_spell = false;
    var _ap_spell_loc_id = undefined; // AP location ID for this town's
    if (global.AP_connected && variable_global_exists("ap_location_name_to_id")
    &&  !is_undefined(g.town_name) && g.town_name != "")
    {
        var _loc_desc = STR_Spell+STR_Location+g.town_name;
        _ap_spell_loc_id = ds_map_find_value(global.ap_location_name_to_id, _loc_desc);
        show_debug_message("AP_SPELL1A: town='" + string(g.town_name) + "' desc='" + _loc_desc + "' ap_id=" + string(_ap_spell_loc_id));
    }
    if (!is_undefined(_ap_spell_loc_id) && variable_global_exists("ap_scouted_item_types"))
    {
        var _rmp_scouted = global.ap_scouted_item_types[?_ap_spell_loc_id];
        var _rmp_cur_name = val(g.dm_Spell[?hex_str(_BIT)+STR_Name], "");
        if (_rmp_cur_name == "") _rmp_cur_name = val(g.dialogue_source.give_spell_name, "");
        if (is_undefined(_rmp_scouted) || _rmp_scouted == "")
        {
            // Cross-world item — no ZALiA spell dialogue
            _ap_non_spell = true;
        }
        else if (_rmp_scouted != _rmp_cur_name)
        {
            if (Rando_is_spell(_rmp_scouted))
            {
                // Different AP spell — swap dialogue_datakey
                var _rmp_new_dlg = val(g.dm_spawn[?STR_Spell+STR_Dialogue+STR_Datakey+_rmp_scouted], "");
                if (_rmp_new_dlg != "")
                    g.dialogue_source.dialogue_datakey = _rmp_new_dlg;
                var _rmp_new_bit = val(g.dm_Spell[?_rmp_scouted+STR_Bit], 0);
                if (_rmp_new_bit == 0)
                {
                    var _rmp_new_sdk = val(g.dm_spawn[?STR_Spell+STR_Spawn+STR_Datakey+_rmp_scouted], "");
                    if (_rmp_new_sdk != "")
                        _rmp_new_bit = val(g.dm_spawn[?STR_Spell+STR_Bit+_rmp_new_sdk], 0);
                }
                if (_rmp_new_bit != 0)
                {
                    g.dialogue_source.give_spell = _rmp_new_bit;
                    _BIT = _rmp_new_bit;
                }
                show_debug_message("AP_SPELL1A: remapped dialogue to AP spell " + _rmp_scouted + " bit=$" + hex_str(_BIT));
            }
            else
            {
                // Non-spell ZALiA item — use boulder circle
                _ap_non_spell = true;
            }
        }
    }

    // Under AP, f.spells can already carry this
    var _already_learned_here = f.spells&_BIT;
    if (global.AP_connected && !is_undefined(_ap_spell_loc_id))
    {
        _already_learned_here = ds_list_find_index(global.ap_checked_ids, _ap_spell_loc_id) != -1;
    }

    if (_already_learned_here)
    {
        // In AP mode every spell uses "D" (boulder
        if (_BIT!=SPL_SUMM || global.AP_connected)
            dialogue_ver = "D"; // Which boulder to break
        else
            dialogue_ver = "B"; // Vanilla only: "I don't know any more spells"
    }
    else if (_ap_non_spell)
    {
        // Non-spell/cross-world AP item: show boulder-circle hint
        dialogue_ver = "D";
        if (!is_undefined(_ap_spell_loc_id) && ds_list_find_index(global.ap_checked_ids, _ap_spell_loc_id) == -1)
        {
            show_debug_message("AP_SPELL1A: non-spell item, sending check for ap_id=" + string(_ap_spell_loc_id));
            apclient_location_checks("[" + string(_ap_spell_loc_id) + "]");
            ds_list_add(global.ap_checked_ids, _ap_spell_loc_id);
        }
        break;//case NPC_7
    }
    else if (g.mod_AcquireSpellRequirement==1   // 1: no requirement for spell
         ||  get_stat_max(STR_Magic)>=get_spell_cost(_BIT) ) // if can afford casting cost
    {
        dialogue_ver = "A"; // acquire spell dialogue
        // _ap_grant_local: true = grant spell normally; false
        var _ap_grant_local = true;

        // _ap_spell_loc_id was resolved at the top
        if (!is_undefined(_ap_spell_loc_id))
        {
            show_debug_message("AP_SPELL1A: ap_id=" + string(_ap_spell_loc_id) + " checked=" + string(ds_list_find_index(global.ap_checked_ids, _ap_spell_loc_id)));
            if (ds_list_find_index(global.ap_checked_ids, _ap_spell_loc_id) == -1)
            {
                // First check: send to srv, suppress local
                show_debug_message("AP_SPELL1A: sending check, server will grant item");
                apclient_location_checks("[" + string(_ap_spell_loc_id) + "]");
                ds_list_add(global.ap_checked_ids, _ap_spell_loc_id);
                _ap_grant_local = false;
                // Persist checked ID to file immediately
                var _spsp_dir = environment_get_variable("LOCALAPPDATA");
                if (_spsp_dir == "") _spsp_dir = working_directory;
                var _spsp_path = _spsp_dir + "\ZALiA\ap_checked.json";
                var _spsp_sz = ds_list_size(global.ap_checked_ids);
                var _spsp_str = "[";
                var _spsp_j;
                for (_spsp_j = 0; _spsp_j < _spsp_sz; _spsp_j++)
                {
                    if (_spsp_j > 0) _spsp_str += ",";
                    _spsp_str += string(global.ap_checked_ids[|_spsp_j]);
                }
                _spsp_str += "]";
                var _spsp_fh = file_text_open_write(_spsp_path);
                file_text_write_string(_spsp_fh, _spsp_str);
                file_text_close(_spsp_fh);
            }
            else
            {
                // Already checked (reconnect scenario).
                show_debug_message("AP_SPELL1A: already checked, server re-grants on reconnect");
                dialogue_ver = "B";
                break;//case NPC_7
            }
        }

        if (_ap_grant_local)
        {
            f.spells |= _BIT; // Include this spell bit in acquired
            // if this is the first spell player has acquired
            if!(f.spells & ~_BIT) g.spell_selected = _BIT;
        }
    }
    else
    {
        dialogue_ver = "C"; // come back when ready
    }
    
    if (g.mod_PC_CUCCO_1 
    &&  g.mod_WISEMEN_CAST_SPELL )
    {
        if (g.dialogue_source.use_cucco_dlg==2)
        {   // Special "whoops" dialogue for turning PC into a cucco.
            dialogue_ver = "E";
            break;//case NPC_7
        }
        
        
        if (_BIT==SPL_FARY)
        {
            if (g.dialogue_source.ver==2)
            {   dialogue_ver  = "A";  }
            
            if (dialogue_ver == "A")
            {   // Only when acquiring the spell.
                // Special dialogue will activate after closing pause menu.
                g.dialogue_source.use_cucco_dlg = 1;
            }
        }
    }
    break;}//case NPC_7
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_8:{ // RESCUE FAIRY's friend
    if (f.items&ITM_FRY1) dialogue_ver = "B";
    break;}//case NPC_8
    
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_9:{
    switch(g.dialogue_source.ver)
    {   // --------------------------------------------
        case $2:{ // B4A3, B4A7. Riverman
        if (f.items&ITM_NOTE)
        {
            var _SCENE = val(g.dm_rm[?STR_Saria+STR_Bridge+STR_Scene], Area_TownA+'06');
            f.dm_quests[?f.BuildBridge_QUAL_DK+_SCENE] = true;
            
            dialogue_ver = "B"; // alt dialogue
        }
        break;}//case $2
        
        
        // --------------------------------------------
        case $4:{ // B5B9. Nabooru Ache
        if (g.dialogue_source.talked_to_count>=4) dialogue_ver = "B"; // alt dialogue
        break;}//case $4
        
        
        // --------------------------------------------
        case $5:{ // B5B9. Saria Bot
        if (g.dialogue_source.talked_to_count>=4) dialogue_ver = "B"; // alt dialogue
        break;}//case $5
        
        
        // --------------------------------------------
        case $6:{ // B4EE. Error
        if (val(f.dm_quests[?STR_ErrorFriend])) dialogue_ver = "B"; // alt dialogue
        break;}//case $6
        
        
        // --------------------------------------------
        case $7:{ // B4EE. Error's friend
        f.dm_quests[?STR_ErrorFriend] = true;
        break;}//case $7
        
        
        // --------------------------------------------
        case $8:{ // Scroblin
        if (val(f.dm_quests[?Scroblin_DATAKEY1])) dialogue_ver = "B"; // alt dialogue
        break;}//case $8
        
        
        // --------------------------------------------
        case $A:{ // Malo. BOOK sequence-1. Nabooru Bay
        f.dm_quests[?STR_Malo+STR_State] = 1;
        break;}//case $A
        
        
        // --------------------------------------------
        case $B:{ // Anju. BOOK sequence-2. Rauru
        if (val(f.dm_quests[?STR_Malo+STR_State])) // If have spoken to Malo
        {
            if(!val(f.dm_quests[?STR_Talo+STR_State]))
            {       f.dm_quests[?STR_Talo+STR_State] = 1;  } // 1: "Take this item", 2: "Nothing left to give"
            
            dialogue_ver = "B"; // alt dialogue
        }
        break;}//case $B
        
        
        // --------------------------------------------
        case $C:{ // Talo. BOOK sequence-3. Whale Isl.
        // item_acquired() is a vanilla anti-duplicate guard
        if (!global.AP_connected
        &&  !is_undefined( g.dialogue_source.Item_ITEM_ID)
        &&  item_acquired(g.dialogue_source.Item_ITEM_ID) )
        {          f.dm_quests[?STR_Talo+STR_State] = 2;  } // 1: Give item, 2: "Nothing left to give"
        
        switch(val(f.dm_quests[?STR_Talo+STR_State])){
        default:{dialogue_ver="A"; break;} // "Weather is nice today"
        case  1:{dialogue_ver="B"; break;} // "Take this item"
        case  2:{dialogue_ver="C"; break;} // "Nothing left to give"
        }
        break;}//case $C
        
        
        // --------------------------------------------
        case $E:{ // Boulder Circle "talk to the wisemen" hint
        //f.dm_quests[?STR_Boulder+STR_Circle+STR_Hint] = 1;
        break;}//case $E
        
        
        // --------------------------------------------
        case $F:{ // B5B9. Bulblin Ache
        if (g.dialogue_source.talked_to_count>=4)
        {
                dialogue_ver = "B"; // "ZZZZZZ..."
            if (g.dialogue_source.talked_to_count>=7)
            {
                dialogue_ver = "C";
                var                  _DATAKEY = STR_Scroblin+STR_Open+STR_Path;
                if(!val(f.dm_quests[?_DATAKEY]))
                {       f.dm_quests[?_DATAKEY] = true;  } // Path to Ganon tower
            }
        }
        break;}//case $F
    }//switch(g.dialogue_source.ver)
    break;}//case NPC_9
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_B:{ // Minigame
    dialogue_ver = g.dialogue_source.dialogue_ver;
    break;}//case NPC_B
    
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_D:{ // Shop Owner
    dialogue_ver = g.dialogue_source.dialogue_ver;
    
    if (val(global.dm_save_file_settings[?STR_Randomize+STR_Item+STR_Locations]) 
    &&  dialogue_ver=="C" )
    {
        dialogue_ver ="G"; // G: "I HAVE NOTHING LEFT TO OFFER YOU."
    }
    break;}//case NPC_D
    
    
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case Zelda:{
    switch(g.dialogue_source.ver)
    {
        case 1:{
        dialogue_ver = 'A';
        break;}
        
        case 2:{ // 2nd Quest, North Castle
        dialogue_ver = g.dialogue_source.dialogue_ver; // "01": GOOD LUCK/HINT, "02": TAKE THIS BOTTLE
        break;}
    }
    // var _DK0Z00 = '0Z_00_'; // 
    break;}//case Zelda
    
    
    
    
    
    
    
    // ---------------------------------------------------------------------
    // ---------------------------------------------------------------------
    case NPC_C:{ // Spell Sequence
    var _FONT = val(dm_dialogue[?g.dialogue_source.dialogue_datakey+'A'+STR_Font], global.dl_game_font[|global.game_font_idx]);
    if ((f.items&ITM_BOOK && g.dialogue_source.HylianText_read) 
    ||  _FONT==global.dl_game_font[|global.game_font_idx] )
    {    dialogue_ver='B';  } // Translated text
    else dialogue_ver='A';    // Hylian text
    break;}//case NPC_C
}//switch(g.dialogue_source.object_index)




