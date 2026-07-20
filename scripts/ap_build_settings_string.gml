/// ap_build_settings_string()
{
    var _dm = global.ap_slot_data;
    if (ds_map_size(_dm) == 0)
    {
        show_debug_message("AP: No slot_data available");
        return "{}";
    }
    var _out = ds_map_create();

    // Helper: read a value from the slot_data map
    var _v;
    _v = ds_map_find_value(_dm, "limit_obscure_locations");
    if (!is_undefined(_v)) _out[?dk_LimitObscure] = _v;

    _v = ds_map_find_value(_dm, "dark_room_difficulty");
    if (!is_undefined(_v)) _out[?dk_DarkRoom+STR_Difficulty] = _v;

    _v = ds_map_find_value(_dm, "item_location_hints");
    if (!is_undefined(_v)) _out[?STR_Item+STR_Location+STR_Hint] = _v;

    _v = ds_map_find_value(_dm, "zelda_hint");
    if (!is_undefined(_v)) _out[?STR_Zelda+STR_Hint] = _v;

    _v = ds_map_find_value(_dm, "randomize_item_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Item+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "randomize_pbag_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_PBAG+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "randomize_key_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Key+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "randomize_spell_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Spell+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "randomize_spell_cost");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Spell+STR_Cost] = _v;

    _v = ds_map_find_value(_dm, "randomize_dungeon_rooms");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Dungeon+STR_Room] = _v;

    _v = ds_map_find_value(_dm, "randomize_dungeon_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Dungeon+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "randomize_dungeon_boss");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Dungeon+STR_Boss] = _v;

    _v = ds_map_find_value(_dm, "randomize_town_locations");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Town+STR_Locations] = _v;

    _v = ds_map_find_value(_dm, "enemy_difficulty");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_Difficulty] = _v;

    _v = ds_map_find_value(_dm, "enemy_randomization_method");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_Method] = _v;

    _v = ds_map_find_value(_dm, "randomize_enemy_spawners");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_Spawner] = _v;

    _v = ds_map_find_value(_dm, "enemy_enigma");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_ENIGMA] = _v;

    _v = ds_map_find_value(_dm, "randomize_enemy_hp");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_HP] = _v;

    _v = ds_map_find_value(_dm, "randomize_enemy_damage");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Enemy+STR_Damage] = _v;

    _v = ds_map_find_value(_dm, "randomize_level_cost");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Level+STR_Cost] = _v;

    _v = ds_map_find_value(_dm, "randomize_xp");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_XP] = _v;

    _v = ds_map_find_value(_dm, "randomize_palette");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Palette] = _v;

    _v = ds_map_find_value(_dm, "randomize_dungeon_tileset");
    if (!is_undefined(_v)) _out[?STR_Randomize+STR_Dungeon+STR_Tileset] = _v;

    _v = ds_map_find_value(_dm, "force_quit_penalty");
    if (!is_undefined(_v)) _out[?dk_ForceQuitPenalty] = _v;

    _v = ds_map_find_value(_dm, "starting_quest");
    if (!is_undefined(_v)) _out[?STR_File+STR_Start+STR_Quest] = _v;

    _v = ds_map_find_value(_dm, "starting_attack_level");
    if (!is_undefined(_v)) _out[?STR_File+STR_Start+STR_Level+STR_Attack] = _v;

    _v = ds_map_find_value(_dm, "starting_magic_level");
    if (!is_undefined(_v)) _out[?STR_File+STR_Start+STR_Level+STR_Magic] = _v;

    _v = ds_map_find_value(_dm, "starting_life_level");
    if (!is_undefined(_v)) _out[?STR_File+STR_Start+STR_Level+STR_Life] = _v;

    _v = ds_map_find_value(_dm, "kakusu_required_count");
    if (!is_undefined(_v)) _out[?STR_Kakusu+STR_Required+STR_Count] = _v;

    _v = ds_map_find_value(_dm, "crystals_required_count");
    if (!is_undefined(_v)) _out[?STR_Crystal+STR_Required+STR_Count] = _v;

    var _encoded = json_encode(_out);
    ds_map_destroy(_out); _out = undefined;

    return _encoded;
}
