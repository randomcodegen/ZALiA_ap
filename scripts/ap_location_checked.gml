/// ap_location_checked(len)
{
    var _count = argument0;
    var _added = 0;
    var _i;
    for (_i = 0; _i < _count; _i++)
    {
        var _location_id = real(global.arg_ids[_i]);
        if (_location_id <= 0) continue;
        if (variable_global_exists("ap_created_manifest_ready")
        &&  global.ap_created_manifest_ready
        &&  is_undefined(ds_map_find_value(global.ap_created_location_ids, _location_id)))
            continue;
        if (ds_list_find_index(global.ap_checked_ids, _location_id) == -1)
        {
            ds_list_add(global.ap_checked_ids, _location_id);
            _added++;
        }
    }
    if (_added > 0) ap_refresh_overworld_marks();
    show_debug_message("AP: Location checked event count=" + string(_count)
        + " new=" + string(_added));
}
