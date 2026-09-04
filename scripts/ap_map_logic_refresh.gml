/// ap_map_logic_refresh()
// Recompute only after an inventory batch or slot change.
if (!global.ap_map_logic_dirty || !global.AP_connected) exit;
global.ap_map_logic_ready = false;
ds_map_clear(global.ap_in_logic_ids);
if (!global.ap_logic_inventory_ready) exit;
global.ap_map_logic_dirty = false;

if (global.ap_map_logic == -1)
{
    var _json = global.ap_slot_data[?"map_logic"];
    if (!is_string(_json))
    {
        show_debug_message("AP: Map logic unavailable: this seed has no map_logic slot data; generate a new seed.");
        exit;
    }
    var _data = json_decode(_json);
    if (_data == -1)
    {
        show_debug_message("AP: Map logic JSON decode failed, chars=" + string(string_length(_json)));
        exit;
    }
    if (!ap_map_logic_validate(_data))
    {
        ds_map_destroy(_data);
        show_debug_message("AP: Invalid map logic data; displaying unknown count");
        exit;
    }
    global.ap_map_logic = _data;
    show_debug_message("AP: Map logic loaded from slot data");
}

var _data = global.ap_map_logic;
var _nodes = _data[?"nodes"];
var _edges = _data[?"entrances"];
var _locations = _data[?"locations"];
var _regions = ds_list_create();
var _values = ds_list_create();
repeat(_data[?"region_count"]) ds_list_add(_regions, false);
_regions[|_data[?"start"]] = true;
var _changed = true;
while (_changed)
{
    ds_list_clear(_values);
    for (var _i = 0; _i < ds_list_size(_nodes); _i++)
    {
        var _node = _nodes[|_i];
        var _a = _node[|1];
        var _v = 0;
        switch (_node[|0])
        {
            case "const": _v = _a; break;
            case "item": _v = val(global.ap_logic_item_counts[?_a]); break;
            case "region": _v = _regions[|_a]; break;
            case "&": _v = _values[|_a] && _values[|_node[|2]]; break;
            case "|": _v = _values[|_a] || _values[|_node[|2]]; break;
            case "+": _v = _values[|_a] + _values[|_node[|2]]; break;
            case ">=": _v = _values[|_a] >= _values[|_node[|2]]; break;
            case "!": _v = !_values[|_a]; break;
            case "?":
                if (_values[|_a]) _v = _values[|_node[|2]];
                else _v = _values[|_node[|3]];
                break;
        }
        ds_list_add(_values, _v);
    }
    _changed = false;
    for (var _i = 0; _i < ds_list_size(_edges); _i++)
    {
        var _edge = _edges[|_i];
        var _to = _edge[|1];
        if (_regions[|_edge[|0]] && !_regions[|_to] && _values[|_edge[|2]])
        {
            _regions[|_to] = true;
            _changed = true;
        }
    }
}
for (var _i = 0; _i < ds_list_size(_locations); _i++)
{
    var _loc = _locations[|_i];
    if (_regions[|_loc[|1]] && _values[|_loc[|2]])
        global.ap_in_logic_ids[?_loc[|0]] = true;
}
ds_list_destroy(_regions);
ds_list_destroy(_values);
global.ap_map_logic_ready = true;
show_debug_message("AP: Map logic ready, reachable=" + string(ds_map_size(global.ap_in_logic_ids))
    + " received=" + string(ds_map_size(global.ap_logic_received)));
