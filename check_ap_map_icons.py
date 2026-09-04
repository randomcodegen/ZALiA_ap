"""Run with Python; checks the GML icon decision without a GameMaker runtime."""
from pathlib import Path
import re
from types import SimpleNamespace

root = Path(__file__).resolve().parent
scripts = root / 'scripts'
source = (scripts / 'Overworld_udp.gml').read_text()
condition = re.search(r'if \((global.AP_map_icons .*?)\)\n', source).group(1)
condition = condition.replace('global.', 'settings.').replace('||', 'or').replace('&&', 'and')
condition = condition.replace('!is_undefined(_owner)', '(_owner is not None)')

# Exercise the actual GML condition: local, remote and not-yet-scouted owners.
for enabled, owner, expected in (
    (False, 1, False), (False, 2, True), (False, None, False),
    (True, 1, True), (True, 2, True), (True, None, True),
):
    actual = eval(condition, {'__builtins__': {}}, {
        'settings': SimpleNamespace(AP_map_icons=enabled, ap_local_player=1),
        '_owner': owner,
    })
    assert actual == expected, (enabled, owner)

# Read masks/frames from the existing classification branch (including mixed flags).
branch = source[source.index('var _xflags = 0;'):source.index('// Local item:')]
cases = re.findall(r'if \(_xflags & (\d+)\) _sub = (\d+);', branch)
fallback = int(re.search(r'else\s+_sub = (\d+);', branch).group(1))
for flags, expected in enumerate((0, 2, 1, 2, 0, 2, 1, 2)):
    actual = next((int(frame) for mask, frame in cases if flags & int(mask)), fallback)
    assert actual == expected, flags

for name in ('OptionsMenu_Create', 'OptionsMenu_Draw_RandoOptions',
             'OptionsMenu_RandoOptions_update', 'OptionsMenu_option_is_avail'):
    assert 'Rando_AP_MAP_ICONS' in (scripts / (name + '.gml')).read_text(), name
assert 'global.AP_map_icons = false;' in (scripts / 'g_Create.gml').read_text()
for name in ('save_game_pref', 'load_game_pref'):
    text = (scripts / (name + '.gml')).read_text()
    assert '"AP_MapIcons"' in text and 'global.AP_map_icons' in text, name
print('AP map icon routing, classification and preference wiring passed.')
