/// ap_compute_location_checksum()
{
    var _location_count = val(dm_LOCATIONS[?STR_Total+STR_Location+STR_Count], ds_list_size(dl_location_NUMS));
    var _str = "";
    var _i, _loc_num_, _rm_name, _description;
    for (_i = 1; _i <= _location_count; _i++)
    {
        _loc_num_ = hex_str(_i);
        _rm_name = dm_LOCATIONS[?_loc_num_+STR_Rm+STR_Name];
        if (is_undefined(_rm_name)) continue;
        _description = dm_LOCATIONS[?_loc_num_+STR_Description];
        _str += string(_i) + ":" + string(_rm_name) + ":" + string(_description) + ";";
    }
    return md5_string_utf8(_str);
}
