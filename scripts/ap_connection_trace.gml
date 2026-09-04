/// ap_connection_trace(stage)
// Milliseconds since DLL init and since the previous trace; no payloads/passwords.
var _now = current_time;
show_debug_message("AP TIME +" + string(_now - global.ap_trace_start)
    + "ms delta=" + string(_now - global.ap_trace_last) + "ms | " + argument0);
global.ap_trace_last = _now;
