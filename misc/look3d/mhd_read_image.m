function info = mhd_read_image(filename)
info = mha_read_header(filename);
info.data = mha_read_volume(info);
