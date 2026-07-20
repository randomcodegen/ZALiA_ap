/// Rando_is_qual_location_1a()


//    JUMP && GLOVE && STABDOWN
// && KAKUSU01: JUMP.  *North Castle
// && KAKUSU02:(CANDLE || FIRE) && (JUMP || GLOVE).  *Parapa Palace
// && KAKUSU03: HAMMER || RAFT || (JUMP && (NOTE || FAIRY)).  *DthMt HAMMER caves
// && KAKUSU04:(JUMP || FAIRY) && (HAMMER || RAFT || (JUMP && (NOTE || FAIRY))).  *DthMt bridge
// && KAKUSU05: JUMP && GLOVE && STABDOWN.  *Ruto Mtns
// && KAKUSU06: STABDOWN && GLOVE && FAIRY && JUMP && (RAFT || HAMMER || (JUMP && (NOTE || FAIRY))) && (ALLKEY || P3keys>=4).  *P3
// && KAKUSU07: STABUP && STABDOWN && JUMP && RAFT.  *Darunia
// && KAKUSU08: RAFT.  *Darunia Forest
// && KAKUSU09: FAIRY && STABDOWN && RAFT.  *MazeIsl
// && KAKUSU10: GLOVE && JUMP && FAIRY && FLUTE && RAFT.  *P6
// && KAKUSU11: CROSS && BOOK && ENIGMA && (PROTECT-REFLECT).  *Kasuto Cemetery
// && KAKUSU12: THUNDER && RAFT.  *THUNDER Kakusu

if(!Rando_is_attainable(STR_STABDOWN,STR_GLOVE)  // To get under North Castle Lake
|| !Rando_is_attainable(STR_JUMP) )    // To get over water in room left of Kakusu tomb
{
    return false;
}



var _REQUIRED_COUNT=$C;
var _count=0;


// KAKUSU01: North Castle
if (Rando_is_attainable(STR_JUMP))
{
    _count++;
}



// KAKUSU02: Parapa Palace
if (Rando_is_qual_location(val(dm_save_data[?STR_Dungeon+STR_Rando+STR_Parapa_Palace+"A"], STR_Parapa_Palace)) 
&&  Rando_is_attainable(STR_CANDLE,STR_FIRE) ) // To light the torches
{
    _count++;
}



// KAKUSU03: Death Mtn HAMMER caves
if (Rando_can_reach_Z1Area())
{
    _count++;
}



// KAKUSU04: Death Mtn bridge
if (Rando_can_reach_RoyalCemetery() 
&&  Rando_is_attainable(STR_JUMP,STR_FAIRY) ) // Get across the Kakusu room
{
    _count++;
}



// KAKUSU05: Ruto Mtns
if (Rando_can_reach_RutoMtnRuins()  // bottom of the ruins
&&  Rando_is_attainable(STR_JUMP)   // get to top of ruins
&&  Rando_is_attainable(STR_STABDOWN) ) // kill kakusu
{
    _count++;
}



// KAKUSU06: P3
if (Rando_is_qual_location(val(dm_save_data[?STR_Dungeon+STR_Rando+STR_Island_Palace+"A"], STR_Island_Palace))
&&  Rando_is_attainable(STR_GLOVE)      // key & block wall
&&  Rando_is_attainable(STR_STABDOWN)   // kill kakusu
&& (Rando_is_attainable(STR_ALLKEY) // reach the Kakusu room deep in
||  Rando_attainable_key_count(val(g.dm_dungeon[?STR_Dungeon+STR_Num+STR_Island_Palace],3))>=4) )
{
    _count++;
}



// KAKUSU07: Darunia
if (Rando_is_qual_location(val(dm_save_data[?STR_Town+STR_Rando+STR_Darunia+"A"], STR_Darunia)) 
&&  Rando_can_traverse_Darunia_town()  // in case Darunia is Old Kasuto and don't have CROSS
&&  Rando_is_attainable(STR_STABDOWN) 
&&  Rando_is_attainable(STR_STABUP) 
&&  Rando_is_attainable(STR_GLOVE) 
&&  Rando_is_attainable(STR_JUMP) )
{
    _count++;
}



// KAKUSU08: Darunia Forest
if (Rando_can_reach_DaruniaField())
{
    _count++;
}



// KAKUSU09: Maze Isl
if (Rando_can_reach_MazeIsl() 
&&  Rando_is_attainable(STR_FAIRY) )
{
    _count++;
}



// KAKUSU10: P6
if (Rando_is_qual_location(val(dm_save_data[?STR_Dungeon+STR_Rando+STR_Three_Eye_Rock_Palace+"A"], STR_Three_Eye_Rock_Palace)))
{
    if (Rando_is_attainable(STR_ALLKEY) 
    ||  Rando_attainable_key_count(val(g.dm_dungeon[?STR_Dungeon+STR_Num+STR_Three_Eye_Rock_Palace],6))>=6 )
    {
        if (Rando_are_attainable(STR_FAIRY,STR_JUMP) // To get across P6 lava room
        &&  Rando_is_attainable(STR_STABDOWN)  // To kill 2nd Rebo
        &&  Rando_is_attainable(STR_GLOVE) )   // room with block wall
        {
            _count++;
        }
    }
}



// KAKUSU11: Kasuto Cemetery
if (Rando_can_reach_KasutoArea() 
&&  Rando_is_attainable(STR_CROSS) 
&&  Rando_is_attainable(STR_BOOK) )
//&&  Rando_is_attainable(STR_ENIGMA) ) // use ENIGMA to take care of invisible Moas
{
    var _dk = STR_Spell+STR_Sequence+"03";
    var _spell_seq = f.dm_quests[?_dk];
    if(!is_undefined(_spell_seq))
    {
        var _i, _spell_name;
        
        _count++;
        _spell_seq = val(dm_save_data[?_dk], _spell_seq);
        
        var          _COUNT = string_length(_spell_seq)>>1; // _spell_seq is a string of 4 spell bits
        for(_i=0; _i<_COUNT; _i++)
        {
            _spell_name = string_copy(_spell_seq, (_i<<1)+1, 2);
            _spell_name = g.dm_Spell[?_spell_name+STR_Name];
            if (is_undefined(         _spell_name) 
            || !Rando_is_attainable(  _spell_name) )
            {
                _count--;
                break;//_i
            }
        }
    }
}



// KAKUSU12: THUNDER Kakusu
if (Rando_is_attainable(STR_RAFT) 
&&  Rando_can_traverse_NIslMtnPass() 
&&  Rando_is_attainable(STR_THUNDER) )
{
    _count++;
}





return _count >= _REQUIRED_COUNT;




