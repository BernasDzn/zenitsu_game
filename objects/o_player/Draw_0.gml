// 1. Calculate the lean based on horizontal speed
var _lean = hsp * -0.02;

// 2. Build a custom transformation matrix
var _matrix = matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1);
_matrix[4] = _lean; // Apply shear
matrix_set(matrix_world, _matrix);

// --- SPICE: VISUAL CHARGE SHAKE ---
var _draw_x = 0;
var _draw_y = 0;

if (is_attacking && image_index == 0) {
    // Calculate how intense the shake should be based on charge
    var _shake_intensity = (charge_timer / charge_max) * 2.5; // Max 2.5 pixels of shake
    
    // Generate random offsets
    _draw_x = random_range(-_shake_intensity, _shake_intensity);
    _draw_y = random_range(-_shake_intensity, _shake_intensity);
}

// --- SPICE: IMPACT FLASH ---
if (attack_flash > 0) {
    // Turn on pure white fog that overrides all sprite colors
    gpu_set_fog(true, c_white, 0, 1);
}

// 3. Draw the sprite with the shake offsets applied
// Draw the player applying the dynamic scale multipliers
draw_sprite_ext(
    sprite_index, 
    image_index, 
    _draw_x, // <-- Replaced 'x' to draw at the matrix origin (plus shake)
    _draw_y, // <-- Replaced 'y' to draw at the matrix origin (plus shake)
    image_xscale * draw_scale_x, 
    image_yscale * draw_scale_y, 
    image_angle, 
    image_blend, 
    image_alpha
);

// Turn off the flash immediately after drawing and tick down the timer
if (attack_flash > 0) {
    gpu_set_fog(false, c_black, 0, 0);
    attack_flash -= 1;
}

// 4. Reset the matrix
matrix_set(matrix_world, matrix_build_identity());

// Only draw hitboxes if debug mode is active
if (debug_hitboxes) {
    
    // 1. Draw Regular Attack Hitbox (Red)
    if (is_attacking && image_index == 1) {
        draw_set_color(c_red);
        draw_set_alpha(0.4); // Semi-transparent fill
        draw_rectangle(debug_box_x1, debug_box_y1, debug_box_x2, debug_box_y2, false);
        
        draw_set_color(c_maroon);
        draw_set_alpha(0.8); // Solid outline
        draw_rectangle(debug_box_x1, debug_box_y1, debug_box_x2, debug_box_y2, true);
    }
    
    // 2. Draw Dash Area Damage Hitbox (Aqua)
    if (debug_dash_timer > 0) {
        debug_dash_timer -= 1;
        draw_set_color(c_aqua);
        draw_set_alpha(0.4);
        draw_rectangle(debug_dash_x1, debug_dash_y1, debug_dash_x2, debug_dash_y2, false);
        
        draw_set_color(c_blue);
        draw_set_alpha(0.8);
        draw_rectangle(debug_dash_x1, debug_dash_y1, debug_dash_x2, debug_dash_y2, true);
    }
    
    // Reset alpha and color to default to avoid breaking other drawings
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}