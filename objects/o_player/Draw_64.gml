//// 1. Set the alignment once for all the text
//draw_set_alpha(1.0);
//draw_set_halign(fa_left);
//draw_set_valign(fa_top);
//
//// 2. Define layout variables so you can tweak everything from here
//var _xx = 15;
//var _yy = 15;
//var _scale = 2; // Change this to 1.5, 2, or 3 to make the text bigger!
//var _sep = 20 * _scale; // Automatically increases line spacing based on your scale
//var _shd = 2; // The shadow offset
//
//// 3. Store the strings so you only type them once (guarantees perfect alignment)
//var _t1 = "Dash: " + string(alarm[0]);
//var _t2 = "Trail Alpha: " + string(o_trail.transparency);
//var _t3 = "X Pos: " + string(round(x));
//var _t4 = "X Scale: " + string(image_xscale);
//var _t5 = "Trail Dir: " + string(o_trail.dir);
//
//// 4. Draw the text shadow (Black)
//draw_set_color(c_black);
//draw_text_transformed(_xx + _shd, _yy,            _t1, _scale, _scale, 0);
//draw_text_transformed(_xx + _shd, _yy + _sep,     _t2, _scale, _scale, 0);
//draw_text_transformed(_xx + _shd, _yy + _sep * 2, _t3, _scale, _scale, 0);
//draw_text_transformed(_xx + _shd, _yy + _sep * 3, _t4, _scale, _scale, 0);
//draw_text_transformed(_xx + _shd, _yy + _sep * 4, _t5, _scale, _scale, 0);
//
//// 5. Draw the main text (White)
//draw_set_color(c_white);
//draw_text_transformed(_xx, _yy,            _t1, _scale, _scale, 0);
//draw_text_transformed(_xx, _yy + _sep,     _t2, _scale, _scale, 0);
//draw_text_transformed(_xx, _yy + _sep * 2, _t3, _scale, _scale, 0);
//draw_text_transformed(_xx, _yy + _sep * 3, _t4, _scale, _scale, 0);
//draw_text_transformed(_xx, _yy + _sep * 4, _t5, _scale, _scale, 0);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// ============================================================================
// 1. DYNAMIC DASH CHARGE BAR
// ============================================================================

var _bar_width = 250;
var _bar_height = 12;
var _bar_x = 30;
var _bar_y = _gui_h - 40; 

// Calculate Fill Percentage
var _fill = 1.0; 
if (!hkrk_issen && alarm[0] > 0) {
    _fill = 1.0 - (alarm[0] / cooldown); 
    ui_was_charging = true;
} else if (ui_was_charging) {
    // TRIGGER ANIMATION: When the bar hits 100%, pop the scale and flash white
    ui_flash_alpha = 1.0;
    ui_bar_scale_y = 2.5; // Thicker bar pop
    ui_was_charging = false;
}

// Smoothly ease the animations back to normal every frame
ui_flash_alpha = lerp(ui_flash_alpha, 0, 0.08);
ui_bar_scale_y = lerp(ui_bar_scale_y, 1.0, 0.15);

var _current_height = _bar_height * ui_bar_scale_y;
var _adjusted_y = _bar_y - (_current_height - _bar_height) / 2; // Keeps the bar centered when it pops

// Colors
var _color_bg = c_black;
var _color_fill = hkrk_issen ? c_aqua : merge_color(c_red, c_orange, _fill); 

// Draw Background
draw_set_alpha(0.6);
draw_rectangle_color(_bar_x, _adjusted_y, _bar_x + _bar_width, _adjusted_y + _current_height, 
                     _color_bg, _color_bg, _color_bg, _color_bg, false);
draw_set_alpha(1.0);

// Draw the expanding fill
var _current_width = _bar_width * _fill;
if (_current_width > 0) {
    draw_rectangle_color(_bar_x, _adjusted_y, _bar_x + _current_width, _adjusted_y + _current_height, 
                         _color_fill, _color_fill, _color_fill, _color_fill, false);
}

// --- ADDITIVE BLENDING FOR UI GLOW & SPARKLES ---
gpu_set_blendmode(bm_add);

// 1. The White Flash when fully charged
if (ui_flash_alpha > 0) {
    draw_set_alpha(ui_flash_alpha);
    draw_rectangle_color(_bar_x, _adjusted_y, _bar_x + _bar_width, _adjusted_y + _current_height, 
                         c_white, c_white, c_white, c_white, false);
    draw_set_alpha(1.0);
}

// 2. The Sweeping "Shine" Effect when ready
if (hkrk_issen) {
    // Move a coordinate across the bar over time
    var _sweep_x = (current_time * 0.25) % (_bar_width * 2) - (_bar_width * 0.5);
    
    // Only draw the shine if it's currently over the bar
    if (_sweep_x > 15 && _sweep_x < _bar_width-15) {
        draw_set_alpha(0.5);
        draw_rectangle_color(_bar_x + _sweep_x - 15, _adjusted_y, _bar_x + _sweep_x + 15, _adjusted_y + _current_height, 
                             c_white, c_white, c_white, c_white, false);
        draw_set_alpha(1.0);
    }
}
gpu_set_blendmode(bm_normal);

// Draw the crisp outer border
draw_rectangle_color(_bar_x, _adjusted_y, _bar_x + _bar_width, _adjusted_y + _current_height, 
                     c_white, c_white, c_white, c_white, true);


// ============================================================================
// 2. PROCEDURAL MINIMAP (Code Only)
// ============================================================================

// Minimap Dimensions and Placement (Top Right Corner)
var _map_w = 200;
var _map_h = 120;
var _map_x = _gui_w - _map_w - 20;
var _map_y = 20;

// Scale factors: How much to shrink the room coordinates to fit inside the minimap box
var _scale_x = _map_w / room_width;
var _scale_y = _map_h / room_height;

// Draw Minimap Background (Dark glass look)
draw_set_alpha(0.7);
draw_rectangle_color(_map_x, _map_y, _map_x + _map_w, _map_y + _map_h, 
                     c_black, c_black, c_black, c_black, false);
draw_set_alpha(1.0);

// Draw Map Border
draw_rectangle_color(_map_x, _map_y, _map_x + _map_w, _map_y + _map_h, 
                     c_dkgray, c_dkgray, c_dkgray, c_dkgray, true);

// ============================================================================
// 1. DRAW GROUND (Draw this first so it sits behind the entities)
// ============================================================================

if (instance_exists(o_ground)) {
    
    // Calculate absolute world boundaries
    with (o_ground) {
        other._x1 = min(bbox_left, other._x1);
        other._x2 = max(bbox_right, other._x2);
        other._y1 = min(bbox_top, other._y1);
        other._y2 = max(bbox_bottom, other._y2);
    }
    
    // Scale the world boundaries down, and force them to stay inside the map border
    var _map_gx1 = clamp(_map_x + (_x1 * _scale_x), _map_x, _map_x + _map_w);
    var _map_gy1 = clamp(_map_y + (_y1 * _scale_y), _map_y, _map_y + _map_h);
    var _map_gx2 = clamp(_map_x + (_x2 * _scale_x), _map_x, _map_x + _map_w);
    var _map_gy2 = clamp(_map_y + (_y2 * _scale_y), _map_y, _map_y + _map_h);
    
    // Draw the properly scaled and clamped gray rectangle
    draw_rectangle_colour(_map_gx1, _map_gy1, _map_gx2, _map_gy2, c_gray, c_gray, c_gray, c_gray, false);
}

// ============================================================================
// 2. DRAW ENTITIES
// ============================================================================

// Draw Player (Cyan Dot)
var _px = clamp(_map_x + (x * _scale_x), _map_x, _map_x + _map_w);
var _py = clamp(_map_y + (y * _scale_y), _map_y, _map_y + _map_h) - 4;
draw_circle_color(_px, _py, 3, c_aqua, c_aqua, false);

// Draw Enemies (Red Dots)
if (instance_exists(o_dummy)) {
    with (o_dummy) {
        var _ex = clamp(_map_x + (x * _scale_x), _map_x, _map_x + _map_w);
        var _ey = clamp(_map_y + (y * _scale_y), _map_y, _map_y + _map_h) - 4;
        draw_circle_color(_ex, _ey, 2, c_red, c_red, false);
    }
}

// ============================================================================
// 3. PLAYER HEALTH BAR (Top Left)
// ============================================================================
var _hp_bar_w = 300;
var _hp_bar_h = 24;
var _hp_bar_x = 30;
var _hp_bar_y = 30;

var _hp_percent = clamp(hp / hp_max, 0, 1);

// Draw Background (Dark Gray)
draw_set_alpha(0.8);
draw_rectangle_color(_hp_bar_x, _hp_bar_y, _hp_bar_x + _hp_bar_w, _hp_bar_y + _hp_bar_h, 
                     c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
draw_set_alpha(1.0);

// Draw the Fill (Green, turning red as it drops)
var _hp_color = merge_color(c_red, c_green, _hp_percent);

if (_hp_percent > 0) {
    draw_rectangle_color(_hp_bar_x, _hp_bar_y, _hp_bar_x + (_hp_bar_w * _hp_percent), _hp_bar_y + _hp_bar_h, 
                         _hp_color, _hp_color, _hp_color, _hp_color, false);
}

// Draw the Border
draw_rectangle_color(_hp_bar_x, _hp_bar_y, _hp_bar_x + _hp_bar_w, _hp_bar_y + _hp_bar_h, 
                     c_white, c_white, c_white, c_white, true);

// Add HP Text
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(_hp_bar_x + 10, _hp_bar_y + (_hp_bar_h / 2), "HP: " + string(round(hp)));
draw_set_valign(fa_top); // Reset alignment

// --- SCORE DISPLAY (Top Right) ---
var _score_string = "SCORE: " + string(round(display_score));

draw_set_halign(fa_right);
draw_set_valign(fa_middle);
draw_set_font(f_gamefont);

// Calculate violent offsets if the UI is glitching
var _offset_x = (ui_glitch_frames > 0) ? irandom_range(-5, 5) : 0;
var _offset_y = (ui_glitch_frames > 0) ? irandom_range(-5, 5) : 0;

// 1. Draw Red Channel
draw_set_color(#FF2222);
draw_text_transformed(_gui_w - 30 + _offset_x, 40 - _offset_y, _score_string, score_scale, score_scale, 0);

// 2. Draw Cyan Channel
draw_set_color(#22FFFF);
draw_text_transformed(_gui_w - 30 - _offset_x, 40 + _offset_y, _score_string, score_scale, score_scale, 0);

// 3. Draw Core White Text
draw_set_color(c_white);
draw_text_transformed(_gui_w - 30, 40, _score_string, score_scale, score_scale, 0);

// Reset alignments
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// --- GAME OVER SCREEN ---
if (is_dead) {
    // 1. Draw darkening overlay
    var _alpha = min(dead_timer / 60, 0.75); // Fades in over 1 second
    draw_set_alpha(_alpha);
    draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1.0);
    draw_set_font(f_gamefont);
    
    // 2. Draw Text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    draw_set_color(c_red);
    draw_text_transformed(_gui_w / 2, _gui_h / 2 - 60, "GAME OVER", 3, 3, 0);
    
    draw_set_color(c_white);
    draw_text_transformed(_gui_w / 2, _gui_h / 2, "FINAL SCORE: " + string(global.player_score), 1.5, 1.5, 0);
    
    // Blink the restart prompt
    if (dead_timer % 60 < 30) {
        draw_text(_gui_w / 2, _gui_h / 2 + 60, "Press 'R' to Restart");
    }
    
    // Reset alignments
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}