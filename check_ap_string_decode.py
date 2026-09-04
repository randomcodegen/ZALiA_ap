"""Run with Python to verify the actual GML unescape expression against DLL escaping."""
from pathlib import Path
import re

source = (Path(__file__).resolve().parent / 'scripts/obj_ap_client_Step.gml').read_text()
expression = re.search(r'_j_val = (string_replace_all\(_raw, .*\));', source).group(1)
# Exact seven-character replacement emitted by gm-apclientpp escape_inplace().
escape = "'+" + chr(34) + "'" + chr(34) + "+'"
samples = ["", "plain text", "Zelda's hint", "''", 'quotes: " and backslash: \\',
           "literal escape: " + escape, "Unicode: \u00e9\u96ea's", "{data:" + "abc'def" * 3000 + "}"]
for original in samples:
    encoded = original.replace("'", escape)
    decoded = eval(expression, {'__builtins__': {}}, {
        '_raw': encoded, 'chr': chr,
        'string_replace_all': lambda text, old, new: text.replace(old, new),
    })
    assert decoded == original, original[:80]
assert 'while (_pos <= string_length(_raw))' not in source
print('Native unescape expression passed apostrophe, Unicode and long-payload checks.')
