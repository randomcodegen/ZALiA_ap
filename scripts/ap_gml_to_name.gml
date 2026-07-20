/// ap_gml_to_name(gml_item_id)
{
    var _id = argument0;
    if (_id == "" || is_undefined(_id)) return "";

    // Tools
    switch (_id)
    {
        case STR_CANDLE:   return "Candle";
        case STR_GLOVE:    return "Glove";
        case STR_RAFT:     return "Raft";
        case STR_BOOTS:    return "Boots";
        case STR_FLUTE:    return "Flute";
        case STR_CROSS:    return "Cross";
        case STR_HAMMER:   return "Hammer";
        case STR_BRACELET: return "Bracelet";
        case STR_MIRROR:   return "Mirror";
        case STR_FLOWER:   return "Flower";
        case STR_BOOK:     return "Book";
        case STR_MEAT:     return "Meat";
        case STR_SHIELD:   return "Shield";
        case STR_ALLKEY:   return "AllKey";
        case STR_PENDANT:  return "Pendant";
        case STR_SWORD:    return "Sword";
        case STR_TROPHY:   return "Trophy";
        case STR_RING:     return "Ring";
        case STR_MASK:     return "Mask";
        case STR_NOTE:     return "Note";
        case STR_MAP1:     return "Map (Nabooru)";
        case STR_MAP2:     return "Map (New Kasuto)";
        case STR_CHILD:    return "Child";
        case STR_RFAIRY:   return "Rescue Fairy";
        case STR_BOTTLE:   return "Bottle";
    }

    // Spells
    switch (_id)
    {
        case STR_PROTECT:  return "Spell: Shield";
        case STR_JUMP:     return "Spell: Jump";
        case STR_HEAL:     return "Spell: Heal";
        case STR_FAIRY:    return "Spell: Fairy";
        case STR_FIRE:     return "Spell: Fire";
        case STR_REFLECT:  return "Spell: Reflect";
        case STR_ENIGMA:   return "Spell: Enigma";
        case STR_THUNDER:  return "Spell: Thunder";
        case STR_SUMMON:   return "Spell: Summon";
    }

    // Skills
    switch (_id)
    {
        case STR_STABDOWN: return "Skill: Stab Down";
        case STR_STABUP:   return "Skill: Stab Up";
    }

    // Container pieces
    if (string_pos(STR_HEART, _id) == 1) return "Container Piece (HP)";
    if (string_pos(STR_MAGIC, _id) == 1) return "Container Piece (MP)";

    // Keys — derive palace from the ID suffix
    if (string_pos(STR_KEY, _id) == 1)
    {
        var _palace_hex = string_copy(_id, string_length(STR_KEY)+1, 2);
        switch(str_hex(_palace_hex))
        {
            case 1: return "Small Key (Parapa)";
            case 2: return "Small Key (Midoro)";
            case 3: return "Small Key (Island)";
            case 4: return "Small Key (Maze)";
            case 5: return "Small Key (Sea)";
            case 6: return "Small Key (Three Eye)";
        }
        return "Small Key (Parapa)"; // fallback
    }

    // 1-Up Dolls
    if (string_pos(STR_1UP, _id) == 1) return "1-Up Doll";

    // P-Bags
    if (string_pos(STR_PBAG, _id) == 1) return "P-Bag";

    return "";
}
