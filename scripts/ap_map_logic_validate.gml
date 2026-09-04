/// ap_map_logic_validate(decoded_map)
var _data = argument0;
if (val(_data[?"version"], -1) != 1) return false;
var _rc = _data[?"region_count"];
var _start = _data[?"start"];
if (!is_real(_rc) || _rc < 1 || _rc > 512 || _rc != floor(_rc)) return false;
if (!is_real(_start) || _start < 0 || _start >= _rc || _start != floor(_start)) return false;
var _list = _data[?"nodes"];
if (!is_real(_list) || !ds_exists(_list, ds_type_list)) return false;
_list = _data[?"entrances"];
if (!is_real(_list) || !ds_exists(_list, ds_type_list)) return false;
_list = _data[?"locations"];
if (!is_real(_list) || !ds_exists(_list, ds_type_list)) return false;
var _nodes = _data[?"nodes"];
var _nc = ds_list_size(_nodes);
if (_nc < 1 || _nc > 8192) return false;
for (var _i = 0; _i < _nc; _i++)
{
    var _row = _nodes[|_i];
    if (!is_real(_row) || !ds_exists(_row, ds_type_list)) return false;
    var _size = ds_list_size(_row);
    if (_size < 2) return false;
    var _op = _row[|0];
    var _a = _row[|1];
    if (_op == "const" || _op == "region" || _op == "item")
    {
        if (_size != 2) return false;
        if (_op == "item") { if (!is_string(_a)) return false; }
        else if (!is_real(_a) || _a < 0 || _a != floor(_a)) return false;
        if (_op == "region" && _a >= _rc) return false;
    }
    else
    {
        var _expected = 3;
        if (_op == "!") _expected = 2;
        else if (_op == "?") _expected = 4;
        else if (_op != "&" && _op != "|" && _op != "+" && _op != ">=") return false;
        if (_size != _expected) return false;
        for (var _j = 1; _j < _size; _j++)
        {
            var _ref = _row[|_j];
            if (!is_real(_ref) || _ref < 0 || _ref >= _i || _ref != floor(_ref)) return false;
        }
    }
}
var _seen = ds_map_create();
var _valid = true;
for (var _kind = 0; _kind < 2; _kind++)
{
    var _rows = _data[?"entrances"];
    if (_kind == 1) _rows = _data[?"locations"];
    if (ds_list_size(_rows) > 4096) { _valid = false; break; }
    for (var _i = 0; _i < ds_list_size(_rows); _i++)
    {
        var _row = _rows[|_i];
        if (!is_real(_row) || !ds_exists(_row, ds_type_list)) { _valid = false; break; }
        if (ds_list_size(_row) != 3) { _valid = false; break; }
        for (var _j = 0; _j < 3; _j++)
        {
            var _n = _row[|_j];
            var _limit = _rc;
            if (_j == 2) _limit = _nc;
            if (!is_real(_n) || _n < 0 || _n != floor(_n)) { _valid = false; break; }
            if (_kind == 1 && _j == 0)
            {
                if (is_undefined(global.ap_created_location_ids[?_n]) || !is_undefined(_seen[?_n]))
                    { _valid = false; break; }
                _seen[?_n] = true;
            }
            else if (_n >= _limit) { _valid = false; break; }
        }
        if (!_valid) break;
    }
    if (!_valid) break;
}
if (ds_map_size(_seen) != ds_map_size(global.ap_created_location_ids)) _valid = false;
ds_map_destroy(_seen);
return _valid;
