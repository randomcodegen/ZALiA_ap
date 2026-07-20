/// ap_item_draw()
{
    // Held/caught items (e.g. an NPC-give item like bagus note)
    if (!can_draw_self) exit;

    draw_sprite_(sprite, 0, drawX, drawY, 0, xScale, yScale);
}
