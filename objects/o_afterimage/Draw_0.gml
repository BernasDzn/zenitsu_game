// Use additive blending for a glowing, energetic look
gpu_set_blendmode(bm_add);

// Draw the ghost trail (you can change c_aqua to c_fuchsia, c_white, etc.)
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_aqua, image_alpha);

// Reset blending
gpu_set_blendmode(bm_normal);