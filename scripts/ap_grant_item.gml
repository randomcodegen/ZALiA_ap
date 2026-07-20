/// ap_grant_item(item_name)
{
    var _name = argument0;
    var _granted = false;
    var _bit;
    var _gml_name = "";

    // Map AP-friendly names to GML item name
    switch (_name)
    {
        // Tools (single-bit items in f.items)
        case "Candle":              _gml_name = STR_CANDLE; break;
        case "Glove":               _gml_name = STR_GLOVE; break;
        case "Raft":                _gml_name = STR_RAFT; break;
        case "Boots":               _gml_name = STR_BOOTS; break;
        case "Flute":               _gml_name = STR_FLUTE; break;
        case "Cross":               _gml_name = STR_CROSS; break;
        case "Hammer":              _gml_name = STR_HAMMER; break;
        case "Bracelet":            _gml_name = STR_BRACELET; break;
        case "Mirror":              _gml_name = STR_MIRROR; break;
        case "Flower":              _gml_name = STR_FLOWER; break;
        case "Book":                _gml_name = STR_BOOK; break;
        case "Meat":                _gml_name = STR_MEAT; break;
        case "Shield":              _gml_name = STR_SHIELD; break;
        case "AllKey":              _gml_name = STR_ALLKEY; break;
        case "Pendant":             _gml_name = STR_PENDANT; break;
        case "Sword":               _gml_name = STR_SWORD; break;
        case "Trophy":              _gml_name = STR_TROPHY; break;
        case "Ring":                _gml_name = STR_RING; break;
        case "Mask":                _gml_name = STR_MASK; break;
        case "Note":                _gml_name = STR_NOTE; break;
        case "Map (Nabooru)":       _gml_name = STR_MAP1; break;
        case "Map (New Kasuto)":    _gml_name = STR_MAP2; break;
        case "Child":               _gml_name = STR_CHILD; break;
        case "Rescue Fairy":        _gml_name = STR_RFAIRY; break;
        case "Bottle":              _gml_name = STR_BOTTLE; break;
    }

    if (_gml_name != "")
    {
        _bit = val(g.dm_ITEM[?_gml_name+STR_Bit]);
        if (_bit > 0 && !(f.items & _bit))
        {
            f.items |= _bit;
            _granted = true;
            if (_gml_name == STR_BOOTS)
            {
                Overworld_tile_change_2a(global.OVERWORLD.TileChangeEvent_TYPE_BOOT1);
            }
            if (_gml_name == STR_RFAIRY)
            {
                g.StatRestore_timer_hp = get_stat_max(STR_Heart);
            }
        }
    }
    else
    {
    switch (_name)
    {


        // Spells (bits in f.spells)
        case "Spell: Shield":   if !(f.spells & SPL_PRTC){f.spells|=SPL_PRTC;_granted=true;} break;
        case "Spell: Jump":     if !(f.spells & SPL_JUMP){f.spells|=SPL_JUMP;_granted=true;} break;
        case "Spell: Heal":     if !(f.spells & SPL_LIFE){f.spells|=SPL_LIFE;_granted=true;} break;
        case "Spell: Fairy":    if !(f.spells & SPL_FARY){f.spells|=SPL_FARY;_granted=true;} break;
        case "Spell: Fire":     if !(f.spells & SPL_FIRE){f.spells|=SPL_FIRE;_granted=true;} break;
        case "Spell: Reflect":  if !(f.spells & SPL_RFLC){f.spells|=SPL_RFLC;_granted=true;} break;
        case "Spell: Enigma":   if !(f.spells & SPL_SPEL){f.spells|=SPL_SPEL;_granted=true;} break;
        case "Spell: Thunder":  if !(f.spells & SPL_THUN){f.spells|=SPL_THUN;_granted=true;} break;
        case "Spell: Summon":   if !(f.spells & SPL_SUMM){f.spells|=SPL_SUMM;_granted=true;} break;


        // Skills (bits in f.skills)
        case "Skill: Stab Down":if !(f.skills & SKILL_THD){f.skills|=SKILL_THD;_granted=true;} break;
        case "Skill: Stab Up":  if !(f.skills & SKILL_THU){f.skills|=SKILL_THU;_granted=true;} break;


        // Crystals — set the dungeon
        case "Crystal of Parapa":    if !(f.crystals & ($1<<0)){f.crystals|=($1<<0);_granted=true;} break;
        case "Crystal of Midoro":    if !(f.crystals & ($1<<1)){f.crystals|=($1<<1);_granted=true;} break;
        case "Crystal of Island":    if !(f.crystals & ($1<<2)){f.crystals|=($1<<2);_granted=true;} break;
        case "Crystal of Maze":      if !(f.crystals & ($1<<3)){f.crystals|=($1<<3);_granted=true;} break;
        case "Crystal of Sea":       if !(f.crystals & ($1<<4)){f.crystals|=($1<<4);_granted=true;} break;
        case "Crystal of Three Eye": if !(f.crystals & ($1<<5)){f.crystals|=($1<<5);_granted=true;} break;


        // Keys — find first un-acquired
        case "Small Key (Parapa)":    _granted = ap_grant_key_next(1); break;
        case "Small Key (Midoro)":    _granted = ap_grant_key_next(2); break;
        case "Small Key (Island)":    _granted = ap_grant_key_next(3); break;
        case "Small Key (Maze)":      _granted = ap_grant_key_next(4); break;
        case "Small Key (Sea)":       _granted = ap_grant_key_next(5); break;
        case "Small Key (Three Eye)": _granted = ap_grant_key_next(6); break;


        // Container pieces — find next
        case "Container Piece (HP)": _granted = ap_grant_cont_piece(STR_HEART); break;
        case "Container Piece (MP)": _granted = ap_grant_cont_piece(STR_MAGIC); break;


        // 1-Up Doll — find next
        case "1-Up Doll": _granted = ap_grant_doll(); break;


        // P-Bag (filler)
        case "P-Bag": _granted = ap_grant_pbag(); break;
    }

    if (_granted)
    {
        show_debug_message("AP: Granted item: " + _name);
    }
    else
    {
        show_debug_message("AP: Item already owned or unknown: " + _name);
    }

    return _granted;
    } // end else block
} // end function
