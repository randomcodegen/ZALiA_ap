/// zelda2_require_rom()
// Accept the clean USA ROM with or without its 16-byte iNES header.

var _cacheFile = "zelda2.nes";
var _headeredSha1 = "353489a57f24a429572e76bd455bc51d821f7036";
var _headerlessSha1 = "11333adb723a5975e0ecca3aee8f4747aa8d2d26";
var _romPath, _hash, _romBuffer;

if (file_exists(_cacheFile))
{
    _hash = string_lower(sha1_file(_cacheFile));
    if (_hash==_headeredSha1 || _hash==_headerlessSha1) return true;
    file_delete(_cacheFile);
}

while (true)
{
    _romPath = get_open_filename("Zelda II NES ROM|*.nes", "");
    if (_romPath=="") return false;

    _hash = string_lower(sha1_file(_romPath));
    if (_hash==_headeredSha1 || _hash==_headerlessSha1)
    {
        _romBuffer = buffer_load(_romPath);
        if (_romBuffer!=-1)
        {
            buffer_save(_romBuffer, _cacheFile);
            buffer_delete(_romBuffer);
            return true;
        }
    }

    show_message("That is not the supported Zelda II USA ROM.#Please select a clean headered or headerless dump.");
}
