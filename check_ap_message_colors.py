"""Run with Python: check GML palette, flag precedence and wrapping color slices.

This checks source expressions; drawing and DLL calls still need a GMS smoke test.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent
color = (root / 'scripts/ap_message_color.gml').read_text()
draw = (root / 'scripts/ap_draw_messages.gml').read_text()
receive = (root / 'scripts/ap_print_json.gml').read_text()
palette = {name: tuple(map(int, rgb.split(','))) for name, rgb in re.findall(
    r'case "(\w+)": return make_colour_rgb\(([^)]+)\);', color)}
assert palette == dict(black=(0, 0, 0), red=(238, 0, 0), green=(0, 255, 127),
                      yellow=(250, 250, 210), blue=(100, 149, 237),
                      magenta=(238, 0, 238), cyan=(0, 238, 238),
                      slateblue=(109, 139, 232), plum=(175, 153, 239),
                      salmon=(250, 128, 114), orange=(255, 119, 0))
rules = re.findall(r'if \((_flags & \d+)\) _color = "(\w+)";', color)
for flags, expected in enumerate(('cyan', 'plum', 'slateblue', 'plum',
                                  'salmon', 'plum', 'slateblue', 'plum')):
    actual = 'cyan'
    for expression, name in rules:
        if eval(expression, {'__builtins__': {}}, {'_flags': flags}):
            actual = name
            break
    assert actual == expected, flags
assert re.search(r'_type == "location_id" \|\| _type == "location_name"\) _color = "green"', color)
assert '== global.ap_local_player) _color = "magenta"' in color
assert dict(re.findall(r'case (\d+): _color = "(\w+)";', color)) == {
    '0': 'white', '10': 'slateblue', '20': 'salmon', '30': 'plum', '40': 'green'}

# Evaluate the actual GML color slicing expressions against word and hard wraps.
copy = lambda text, start, count: text[start - 1:start - 1 + count]
delete = lambda text, start, count: text[:start - 1] + text[start - 1 + count:]
helpers = dict(string_copy=copy, string_delete=delete, string_length=len)
line_expr = re.search(r'ds_list_add\(_dl_colors, (string_copy\(.*\))\);', draw).group(1)
rest_expr = re.search(r'_colors = (string_delete\(.*\));', draw).group(1)
code_expr = re.search(r'var _code = (string_copy\(.*\));', draw).group(1)
for text, width in [('PLAYER SENT LONG ITEM (LOCATION)', 10), ('ABCDEFGHIJKLM', 4),
                    ('A  B C', 1), ('', 8), ('AB CD EFGHI', 5)]:
    # A different color at every position exposes off-by-one errors at breaks.
    expected = list(range(1, len(text) + 1))
    colors = ''.join(f'{value:8d}' for value in expected)
    while text:
        ns = len(text) + 1
        line = text
        if len(text) > width:
            bp = width
            while bp > 1 and text[bp - 1] != ' ':
                bp -= 1
            line, ns = (text[:bp - 1], bp + 1) if bp > 1 else (text[:width], width + 1)
        env = dict(helpers, _colors=colors, _line=line, _ns=ns)
        line_colors = eval(line_expr, {'__builtins__': {}}, env)
        assert len(line_colors) == len(line) * 8
        for start, value in enumerate(expected[:len(line)], 1):
            actual = eval(code_expr, {'__builtins__': {}}, dict(helpers, _colors=line_colors, _start=start))
            assert int(actual) == value
        colors = eval(rest_expr, {'__builtins__': {}}, env)
        text, expected = text[ns - 1:], expected[ns - 1:]
        assert len(colors) == len(text) * 8

for filename in ('ap_print_json.gml', 'obj_ap_client_Step.gml'):
    source = (root / 'scripts' / filename).read_text()
    assert 'ds_list_delete(global.ap_message_buffer, 0);\n' in source
    assert 'ds_list_delete(global.ap_message_colors, 0);' in source
assert 'string_repeat(string_format(ap_message_color(_node), 8, 0), string_length(_text))' in receive
assert 'merge_colour(c_black, real(_code), _alpha)' in draw
assert 'scripts\\ap_message_color.gml' in [node.text for node in ET.parse(root / 'ZALiA.project.gmx').iter('script')]
print('AP palette, item flags, hint status, wrapping slices, cleanup and registration checks passed.')
