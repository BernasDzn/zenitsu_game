draw_set_font(f_gamefont);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _base_x = 40;
var _base_y = 40;
var _text = "SCORE: " + string(global.player_score);

// Calculate random glitch offsets if the UI is currently glitching
var _offset_x = (ui_glitch_frames > 0) ? irandom_range(-4, 4) : 0;
var _offset_y = (ui_glitch_frames > 0) ? irandom_range(-4, 4) : 0;

// 1. Draw Red Channel (Shifted)
draw_set_color(c_red);
draw_text_transformed(_base_x + _offset_x, _base_y - _offset_y, _text, ui_scale, ui_scale, ui_angle);

// 2. Draw Blue Channel (Shifted opposite direction)
draw_set_color(c_aqua);
draw_text_transformed(_base_x - _offset_x, _base_y + _offset_y, _text, ui_scale, ui_scale, ui_angle);

// 3. Draw Core White Text (Centered)
draw_set_color(c_white);
draw_text_transformed(_base_x, _base_y, _text, ui_scale, ui_scale, ui_angle);