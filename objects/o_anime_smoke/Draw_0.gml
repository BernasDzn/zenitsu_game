var _scale = sin((life / max_life) * pi);

draw_set_color(c_dkgray);
for(var i = 0; i < blob_count; i++) {
    var _r = blob_max_r[i] * _scale;
    if (_r > 0) draw_circle(x + blob_ox[i], y + blob_oy[i], _r + 4, false);
}

draw_set_color(c_gray);
for(var i = 0; i < blob_count; i++) {
    var _r = blob_max_r[i] * _scale;
    if (_r > 0) draw_circle(x + blob_ox[i], y + blob_oy[i], _r, false);
}