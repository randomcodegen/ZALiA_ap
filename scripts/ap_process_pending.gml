/// ap_process_pending()
{
    show_debug_message("AP_PENDING: called, active=" + string(variable_global_exists("ap_pending_items")));
    if (!variable_global_exists("ap_pending_items") || is_undefined(global.ap_pending_items))
    {
        show_debug_message("AP_PENDING: no pending list, skipping");
        exit;
    }
    if (ds_list_size(global.ap_pending_items) == 0)
    {
        show_debug_message("AP_PENDING: list is empty, skipping");
        exit;
    }

    show_debug_message("AP_PENDING: Processing " + string(ds_list_size(global.ap_pending_items)) + " deferred items after save load (HWM=" + string(global.ap_items_received_index) + ")");

    // Each entry is "index:name".
    var _i, _granted_count, _skipped_count;
    _granted_count = 0;
    _skipped_count = 0;
    for (_i = 0; _i < ds_list_size(global.ap_pending_items); _i++)
    {
        var _entry = global.ap_pending_items[|_i];
        var _colon = string_pos(":", _entry);
        var _item_name = "";
        var _item_idx  = -1;
        if (_colon > 0)
        {
            _item_idx  = real(string_copy(_entry, 1, _colon - 1));
            _item_name = string_copy(_entry, _colon + 1, string_length(_entry) - _colon);
        }
        else
        {
            // Legacy format (no index prefix) — grant
            _item_name = _entry;
        }
        if (_item_idx >= 0 && _item_idx <= global.ap_items_received_index)
        {
            show_debug_message("AP_PENDING: skipping [" + string(_item_idx) + "] " + _item_name + " (already in HWM)");
            _skipped_count++;
            continue;
        }
        show_debug_message("AP_PENDING: granting [" + string(_item_idx) + "] " + _item_name);
        ap_grant_item(_item_name);
        _granted_count++;
    }
    show_debug_message("AP_PENDING: granted=" + string(_granted_count) + " skipped=" + string(_skipped_count));

    ds_list_clear(global.ap_pending_items);

    // Refresh overworld checkmarks now that ap_checked_ids
    ap_refresh_overworld_marks();

    // Advance the HWM
    if (variable_global_exists("ap_pending_max_index") && global.ap_pending_max_index >= 0)
    {
        if (global.ap_pending_max_index > global.ap_items_received_index)
            global.ap_items_received_index = global.ap_pending_max_index;
        global.ap_pending_max_index = -1;
        show_debug_message("AP_PENDING: HWM advanced to " + string(global.ap_items_received_index));
    }
}
