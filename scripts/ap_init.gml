/// ap_init()
{
    global.AP_RENDER_FORMAT_TEXT = 0;
    global.AP_RENDER_FORMAT_HTML = 1;
    global.AP_RENDER_FORMAT_ANSI = 2;
    global.AP_STATE_DISCONNECTED = 0;
    global.AP_STATE_SOCKET_CONNECTING = 1;
    global.AP_STATE_SOCKET_CONNECTED = 2;
    global.AP_STATE_ROOM_INFO = 3;
    global.AP_STATE_SLOT_CONNECTED = 4;
    global.AP_CLIENT_STATUS_UNKNOWN = 0;
    global.AP_CLIENT_STATUS_READY = 10;
    global.AP_CLIENT_STATUS_PLAYING = 20;
    global.AP_CLIENT_STATUS_GOAL = 30;
    global.AP_JSON_MISSING = -1;
    global.AP_JSON_OBJECT = 0;
    global.AP_JSON_ARRAY = 1;
    global.AP_JSON_STRING = 2;
    global.AP_JSON_NUMBER = 3;
    global.AP_JSON_NULL = 4;

    // Slot data and seed (initialized as empty)
    global.ap_slot_data = ds_map_create();
    global.ap_seed = 0;
    global.ap_location_name_to_id = undefined;
    // Individual Kakusu checks are matched by their index
    global.ap_kakusu_id_by_index = undefined;
    // Which Kakusu indices were randomly chosen this seed
    global.ap_kakusu_selected = undefined;
    // Reverse map (AP location id -> location name)
    global.ap_id_to_location_name = ds_map_create();
    // Highest local location number in use
    global.ap_max_loc_num = 168;

    // Location data drift detection (see ap_compute_location_checksum.gml)
    global.ap_slotdata_location_checksum = "";
    global.ap_location_data_stale = false;

    // Message buffer for in-game AP message display
    global.ap_message_buffer = ds_list_create();
    global.ap_message_timers = ds_list_create(); // per-message countdown (frames)

    // Items received high-water mark (prevents double-grant)
    global.ap_items_received_index = -1;

    // Track checked locations for re-send on reconnect
    global.ap_checked_ids = ds_list_create();

    // Local player slot (set on slot connect)
    global.ap_local_player = -1;

    // Scouted item data: populated by ap_location_info
    global.ap_scouted_flags = ds_map_create();
    global.ap_scouted_players = ds_map_create();
    global.ap_scouted_item_ids = ds_map_create();
    global.ap_scouted_item_names = ds_map_create();
    global.ap_scouted_sprites = ds_map_create();
    global.ap_scouted_item_types = ds_map_create();

    // DeathLink support
    global.ap_deathlink_enabled = false;

    // Tracks whether we've ever conn successfully
    global.ap_ever_connected = false;

    // Tracks whether dynamic hints have been generated
    global.ap_hints_generated = false;

    // Pending items processing: set to true after
    global.ap_pending_ready = false;

    // Set to true by file_load.gml once a save is loaded
    global.ap_save_loaded = false;

    // Highest item index seen
    global.ap_pending_max_index = -1;

    // P-Bag XP banked from grants that happened
    global.ap_deferred_xp = 0;

    // Count of 1-Up dolls received from the AP
    global.ap_received_dolls = 0;
}
