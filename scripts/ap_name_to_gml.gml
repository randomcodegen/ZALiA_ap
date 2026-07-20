/// ap_name_to_gml(ap_item_name)
{
    var _ap_name = argument0;

    switch (_ap_name)
    {
        // Tools
        case "Candle":          return STR_CANDLE;
        case "Glove":           return STR_GLOVE;
        case "Raft":            return STR_RAFT;
        case "Boots":           return STR_BOOTS;
        case "Flute":           return STR_FLUTE;
        case "Cross":           return STR_CROSS;
        case "Hammer":          return STR_HAMMER;
        case "Bracelet":        return STR_BRACELET;
        case "Mirror":          return STR_MIRROR;
        case "Flower":          return STR_FLOWER;
        case "Book":            return STR_BOOK;
        case "Meat":            return STR_MEAT;
        case "Shield":          return STR_SHIELD;
        case "AllKey":          return STR_ALLKEY;
        case "Pendant":         return STR_PENDANT;
        case "Sword":           return STR_SWORD;
        case "Trophy":          return STR_TROPHY;
        case "Ring":            return STR_RING;
        case "Mask":            return STR_MASK;
        case "Note":            return STR_NOTE;
        case "Map (Nabooru)":   return STR_MAP1;
        case "Map (New Kasuto)":return STR_MAP2;
        case "Child":           return STR_CHILD;
        case "Rescue Fairy":    return STR_RFAIRY;
        case "Bottle":          return STR_BOTTLE;

        // Spells
        case "Spell: Shield":   return STR_PROTECT;
        case "Spell: Jump":     return STR_JUMP;
        case "Spell: Heal":     return STR_HEAL;
        case "Spell: Fairy":    return STR_FAIRY;
        case "Spell: Fire":     return STR_FIRE;
        case "Spell: Reflect":  return STR_REFLECT;
        case "Spell: Enigma":   return STR_ENIGMA;
        case "Spell: Thunder":  return STR_THUNDER;
        case "Spell: Summon":   return STR_SUMMON;

        // Skills
        case "Skill: Stab Down": return STR_STABDOWN;
        case "Skill: Stab Up":   return STR_STABUP;

        // Keys — return palace-specific name
        case "Small Key (Parapa)":      return STR_KEY + "01";
        case "Small Key (Midoro)":      return STR_KEY + "02";
        case "Small Key (Island)":      return STR_KEY + "03";
        case "Small Key (Maze)":        return STR_KEY + "04";
        case "Small Key (Sea)":         return STR_KEY + "05";
        case "Small Key (Three Eye)":   return STR_KEY + "06";

        // Containers / filler
        case "Container Piece (HP)": return STR_HEART;
        case "Container Piece (MP)": return STR_MAGIC;
        case "1-Up Doll":       return STR_1UP;
        case "P-Bag":           return STR_PBAG;
    }

    return "";
}
