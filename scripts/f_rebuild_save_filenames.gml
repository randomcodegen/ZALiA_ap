/// f_rebuild_save_filenames()


var _i, _prefix, _fn, _file, _data;

var _USE_SEED = (variable_global_exists("AP_connected") && global.AP_connected
             &&  variable_global_exists("ap_seed")      && !is_undefined(global.ap_seed));

var _SEED_TOKEN = "";
if (_USE_SEED)
{
    _SEED_TOKEN = string(global.ap_seed);
    // Guard against any decimal/space formatting sneaking
    _SEED_TOKEN = string_replace_all(_SEED_TOKEN, ".", "");
    _SEED_TOKEN = string_replace_all(_SEED_TOKEN, " ", "");
}


ds_list_clear(f.dl_FILE_NAME_PREFIX);
ds_list_clear(f.dl_file_names);
for(_i=0; _i<SAVE_FILE_MAX; _i++)
{
    if (_USE_SEED) _prefix = "SaveFile_AP"+_SEED_TOKEN+"_"+string(_i+1);
    else           _prefix = "SaveFile_"+string(_i+1);

    ds_list_add(f.dl_FILE_NAME_PREFIX, _prefix);
    ds_list_add(f.dl_file_names, _prefix+".txt");
}


// Repopulate the slot-keyed encoded-data cache for
ds_map_clear(global.dm_save_file_data);
for(_i=0; _i<SAVE_FILE_MAX; _i++)
{
    _fn = f.dl_file_names[|_i];
    if (file_exists(_fn))
    {
        _file = file_text_open_read(working_directory+_fn);
        _data = file_text_read_string(_file);
                file_text_close(_file);
        global.dm_save_file_data[?STR_Save+STR_File+hex_str(_i+1)+STR_Encoded] = _data;
    }
}
