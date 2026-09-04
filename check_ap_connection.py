"""Run with Python to check the client fallback timeout contract."""
from pathlib import Path
import re

scripts = Path(__file__).resolve().parent / 'scripts'
error = (scripts / 'ap_socket_error.gml').read_text()
connected = (scripts / 'ap_socket_connected.gml').read_text()
frames = int(re.search(r'global.AP_error_time = (\d+);', error).group(1))
# APClient starts at 1500ms and doubles its interval on the first attempt.
# Allow the 3000ms fallback delay plus another 3000ms for the handshake.
assert frames / 60 >= 6, 'Game exits before TLS/plain fallback can finish'
assert 'global.AP_error_time = 0;' in connected, 'Successful fallback must cancel shutdown'
assert 'global.AP_last_error = "";' in connected, 'Do not retain a stale TLS error'
print('Connection fallback timeout checks passed.')
