"""Run with Python to check the GML counter's startup and display contract."""
from pathlib import Path
import re

scripts = Path(__file__).resolve().parent / 'scripts'
connected = (scripts / 'ap_slot_connected.gml').read_text()
received = (scripts / 'ap_items_received.gml').read_text()
draw = (scripts / 'Overworld_udp.gml').read_text()
# No item callback is emitted for an empty inventory. Slot setup must be ready.
assert 'global.ap_logic_inventory_ready = true;' in connected
assert connected.index('ds_map_clear(global.ap_logic_received)') < connected.index('global.ap_logic_inventory_ready = true;')
# Nonempty batches must still require a contiguous received-item history.
assert 'ds_map_size(global.ap_logic_received) == global.ap_logic_received_max + 1' in received
expression = re.search(r'_text = (string\(_count2\).*?_logic_text.*?);', draw).group(1)
for checked, logic, total, expected in ((0, '0', 3, '0/0(3)'), (2, '4', 8, '2/4(8)'), (0, '?', 3, '0/?(3)')):
    actual = eval(expression, {'__builtins__': {}}, {'string': str, '_count2': checked, '_logic_text': logic, '_count1': total})
    assert actual == expected, actual
print('Empty-inventory startup and compact counter checks passed.')
