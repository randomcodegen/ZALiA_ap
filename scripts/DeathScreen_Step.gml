/// DeathScreen_Step()


if (deathScreenEndTimer)
{
    deathScreenEndTimer--;
    if(!deathScreenEndTimer)
    {
        f.death_count++;
        if(!g.dev_godmode) lives--; // Godmode: death sequence still plays out
        if (lives>0) room_goto_(rmB_NextLife);
        else         room_goto_(rmB_GameOver);
    }
}




if (deathFlashTimer 
&&  g.timer_b==g.timer_b_DURATION1 ) // timer_b_DURATION1=$14, tmr_b resets at -1. So this happens every 21 frames
{
        deathFlashTimer--;
    if(!deathFlashTimer)
    {
        deathScreenEndTimer = DEATH_SCREEN_END_DUR; // DEATH_SCREEN_END_DUR = 3
    }
}

if (counter==DEATH_FLASH_TIMER_START_CUE) // DEATH_FLASH_TIMER_START_CUE = 4
{
    deathFlashTimer = DEATH_FLASH_TIMER_DUR; // DEATH_FLASH_TIMER_DUR = 7
}

counter++;




