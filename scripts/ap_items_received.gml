/// ap_items_received(index, len)
{
    var _index = argument0;
    var _len = argument1;
    var _i;

    show_debug_message("AP: Items received, index=" + string(_index) + " len=" + string(_len));

    if (!variable_global_exists("ap_items_received_index"))
    {
        global.ap_items_received_index = -1;
    }

    // If save data hasn't been loaded yet
    if (!variable_global_exists("ap_save_loaded") || !global.ap_save_loaded)
    {
        if (!variable_global_exists("ap_pending_items"))
            global.ap_pending_items = ds_list_create();
        for (_i = 0; _i < _len; _i++)
        {
            var _item_id = global.arg_ids[_i];
            if (_item_id < 0) continue;
            // Store "index:name" so ap_process_pending can skip
            var _item_index = _index + _i;
            ds_list_add(global.ap_pending_items, string(_item_index) + ":" + global.arg_names[_i]);
            show_debug_message("AP: Queuing [" + string(_item_index) + "] " + global.arg_names[_i] + " for post-load delivery");
        }
        // Track the highest index covered
        if (!variable_global_exists("ap_pending_max_index"))
            global.ap_pending_max_index = -1;
        var _batch_max = _index + _len - 1;
        if (_batch_max > global.ap_pending_max_index)
            global.ap_pending_max_index = _batch_max;
        // intentionally NOT updating ap_items_received_index yet
    }
    else
    {
        for (_i = 0; _i < _len; _i++)
        {
            var _item_name = global.arg_names[_i];
            var _item_id = global.arg_ids[_i];
            var _player = global.arg_players[_i];

            if (_item_id < 0) continue;

            var _item_index = _index + _i;
            if (_item_index <= global.ap_items_received_index) continue;

            show_debug_message("AP: Receiving " + _item_name + " (ID=" + string(_item_id) + ", player=" + string(_player) + ")");
            ap_grant_item(_item_name);
        }
        global.ap_items_received_index = _index + _len - 1;
    }
}
