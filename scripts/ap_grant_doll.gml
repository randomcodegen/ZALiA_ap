/// ap_grant_doll()
{
    if (!variable_global_exists("ap_received_dolls")) global.ap_received_dolls = 0;

    // Cap so the derived life pool can't overflow
    if (global.ap_received_dolls < 96)
        global.ap_received_dolls += 1;

    show_debug_message("AP: 1-Up Doll received (total received=" + string(global.ap_received_dolls) + ")");

    // Immediate feedback
    if (variable_global_exists("pc") && global.pc != noone && global.pc.x != 0)
    {
        lives = clamp(lives + 1, 1, 99);
    }

    return true;
}
