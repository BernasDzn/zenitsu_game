draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Draw a simple black outline/drop shadow for readability
draw_set_color(c_black);
draw_set_font(f_gamefont);
draw_text(x + 2, y + 2, text);

// Draw the actual colored text
draw_set_color(color);
draw_text(x, y, text);

// Reset alpha and alignment
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);