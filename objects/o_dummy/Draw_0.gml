// 1. FLASH LOGIC
if (hit_flash > 0) {
    gpu_set_fog(true, c_white, 0, 1);
} else if (enemy_type == "bomber" && state == "fuse" && blink_red) {
    gpu_set_fog(true, c_red, 0, 1);
}

// 2. DRAW SPRITE
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
gpu_set_fog(false, c_black, 0, 0);

if (hit_flash > 0) {
    hit_flash -= 1;
}

// 3. HEALTH BAR
var _bar_width = 44; 
var _bar_height = 5; 
var _bar_x = x - (_bar_width / 2); 
var _bar_y = bbox_top - 12; 

var _hp_percent = clamp(hp / hp_max, 0, 1);

// Background
draw_set_color(c_dkgray);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, true);

// Foreground
if (_hp_percent > 0) {
    draw_set_color(c_red);
    draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _hp_percent), _bar_y + _bar_height, false);
}
draw_set_color(c_white);