/// dev_ap_export_data()

var _i, _loc_num_, _rm_name, _category, _obscurity, _description, _item_type, _item_num;
var _qt, _json, _sep, _location_count, _loc_num;


_location_count = val(dm_LOCATIONS[?STR_Total+STR_Location+STR_Count], ds_list_size(dl_location_NUMS));

_qt = chr(34);
_json = "{";

// --- Spells ---
_json += _qt + "spells" + _qt + ":[";
if (!is_undefined(dl_SPELLS))
{
    _sep = "";
    for(_i=0; _i<ds_list_size(dl_SPELLS); _i++)
    {
        _json += _sep + _qt + dl_SPELLS[|_i] + _qt;
        _sep = ",";
    }
}
_json += "],";

// --- Skills ---
_json += _qt + "skills" + _qt + ":[";
if (!is_undefined(dl_SKILLS))
{
    _sep = "";
    for(_i=0; _i<ds_list_size(dl_SKILLS); _i++)
    {
        _json += _sep + _qt + dl_SKILLS[|_i] + _qt;
        _sep = ",";
    }
}
_json += "],";

// --- Towns ---
_json += _qt + "towns" + _qt + ":[";
if (!is_undefined(dl_TOWN_NAMES))
{
    _sep = "";
    for(_i=0; _i<ds_list_size(dl_TOWN_NAMES); _i++)
    {
        _json += _sep + _qt + dl_TOWN_NAMES[|_i] + _qt;
        _sep = ",";
    }
}
_json += "],";

// --- Major items ---
_json += _qt + "major_items" + _qt + ":[";
_sep = "";
var _dl_major = ds_list_create();
ds_list_add(_dl_major,
    STR_CANDLE, STR_GLOVE, STR_RAFT, STR_BOOTS, STR_FLUTE, STR_CROSS,
    STR_HAMMER, STR_BRACELET, STR_MIRROR, STR_FLOWER, STR_BOOK, STR_MEAT,
    STR_SHIELD, STR_ALLKEY, STR_PENDANT, STR_SWORD, STR_TROPHY, STR_RING,
    STR_MASK, STR_NOTE, STR_MAP1, STR_MAP2, STR_CHILD, STR_RFAIRY, STR_BOTTLE
);
for(_i=0; _i<ds_list_size(_dl_major); _i++)
{
    _json += _sep + _qt + _dl_major[|_i] + _qt;
    _sep = ",";
}
ds_list_destroy(_dl_major);
_json += "],";

// --- Container types ---
_json += _qt + "container_types" + _qt + ":[";
_json += _qt + STR_HEART + _qt + ",";
_json += _qt + STR_MAGIC + _qt + "],";

// --- Scalars ---
_json += _qt + "pbag_type" + _qt + ":" + _qt + STR_PBAG + _qt + ",";
_json += _qt + "doll_type" + _qt + ":" + _qt + STR_1UP + _qt + ",";
_json += _qt + "key_type" + _qt + ":" + _qt + STR_KEY + _qt + ",";

// --- Locations ---
_json += _qt + "locations" + _qt + ":[";
_sep = "";
for(_i=1; _i<=_location_count; _i++)
{
    _loc_num_ = hex_str(_i);
    _rm_name = dm_LOCATIONS[?_loc_num_+STR_Rm+STR_Name];
    if (is_undefined(_rm_name)) continue;

    _category    = dm_LOCATIONS[?_loc_num_+STR_Category];
    _obscurity   = dm_LOCATIONS[?_loc_num_+STR_Obscure];
    _description = dm_LOCATIONS[?_loc_num_+STR_Description];
    _item_type   = dm_LOCATIONS[?_loc_num_+STR_Item+STR_Type];
    _item_num    = dm_LOCATIONS[?_loc_num_+STR_Rm+STR_Item+STR_Type+STR_Num];
    _loc_num     = dm_LOCATIONS[?_loc_num_+STR_Rm+STR_Location+STR_Num];
    var _rating  = dm_LOCATIONS[?_loc_num_+STR_ALLKEY+STR_Rating];
    // Which quest(s) this location appears in: "12"
    var _quest   = val(dm_LOCATIONS[?_loc_num_+STR_Qualified+STR_Quest+STR_Nums], "12");

    _json += _sep + "{";
    _json += _qt + "location_num" + _qt + ":" + string(_i) + ",";
    _json += _qt + "room_name" + _qt + ":" + _qt + string(_rm_name) + _qt + ",";
    _json += _qt + "room_loc_num" + _qt + ":" + string(val(_loc_num, 0)) + ",";
    _json += _qt + "category" + _qt + ":" + _qt + string(_category) + _qt + ",";
    _json += _qt + "obscurity" + _qt + ":" + string(val(_obscurity, 0)) + ",";
    _json += _qt + "description" + _qt + ":" + _qt + string(_description) + _qt + ",";
    _json += _qt + "item_type" + _qt + ":" + _qt + string(_item_type) + _qt + ",";
    _json += _qt + "item_num" + _qt + ":" + string(val(_item_num, 1)) + ",";
    _json += _qt + "quest" + _qt + ":" + _qt + string(_quest) + _qt + ",";
    _json += _qt + "rating" + _qt + ":" + string(val(_rating, 0));
    _json += "}";
    _sep = ",";
}
_json += "]";
_json += "}";

show_debug_message("JSON length: " + string(string_length(_json)));

// Also copy to clipboard as a
clipboard_set_text(_json);

// Write to working_directory, same convention as
var _out_path = working_directory + "ap_export_data.json";
var _f = file_text_open_write(_out_path);
file_text_write_string(_f, _json);
file_text_close(_f);
show_debug_message("AP: Wrote location data export to " + _out_path + " (also copied to clipboard).");
