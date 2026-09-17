/// ap_message_color(node) -- Archipelago NetUtils.JSONtoTextParser palette
var _node = argument0;
var _type = _node[? "type"];
var _color = _node[? "color"];
if (_type == "player_id")
{
    _color = "yellow";
    if (real(_node[? "text"]) == global.ap_local_player) _color = "magenta";
}
else if (_type == "player_name") _color = "yellow";
else if (_type == "item_id" || _type == "item_name")
{
    var _flags = _node[? "flags"];
    if (!is_real(_flags)) _flags = 0;
    _color = "cyan";
    if (_flags & 1) _color = "plum";
    else if (_flags & 2) _color = "slateblue";
    else if (_flags & 4) _color = "salmon";
}
else if (_type == "location_id" || _type == "location_name") _color = "green";
else if (_type == "entrance_name") _color = "blue";
else if (_type == "hint_status")
{
    _color = "red";
    switch (_node[? "hint_status"])
    {
        case 0: _color = "white"; break;
        case 10: _color = "slateblue"; break;
        case 20: _color = "salmon"; break;
        case 30: _color = "plum"; break;
        case 40: _color = "green"; break;
    }
}
switch (_color)
{
    case "black": return make_colour_rgb(0, 0, 0);
    case "red": return make_colour_rgb(238, 0, 0);
    case "green": return make_colour_rgb(0, 255, 127);
    case "yellow": return make_colour_rgb(250, 250, 210);
    case "blue": return make_colour_rgb(100, 149, 237);
    case "magenta": return make_colour_rgb(238, 0, 238);
    case "cyan": return make_colour_rgb(0, 238, 238);
    case "slateblue": return make_colour_rgb(109, 139, 232);
    case "plum": return make_colour_rgb(175, 153, 239);
    case "salmon": return make_colour_rgb(250, 128, 114);
    case "orange": return make_colour_rgb(255, 119, 0);
}
return c_white;
