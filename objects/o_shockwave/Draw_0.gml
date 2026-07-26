// Use additive blending for a glowing, scorching effect
gpu_set_blendmode(bm_add);
draw_set_alpha(alpha);

// Outer Ring (Red/Orange)
draw_circle_color(x, y, radius, c_red, c_orange, true);
draw_circle_color(x, y, radius - 1, c_orange, c_orange, true);

// Inner Core (Bright Yellow)
draw_circle_color(x, y, radius - 4, c_yellow, c_yellow, true);

draw_set_alpha(1.0);
gpu_set_blendmode(bm_normal);