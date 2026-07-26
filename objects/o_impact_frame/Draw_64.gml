// Alternate between white and black every single frame
if (life % 2 == 0) {
    draw_set_color(c_white);
} else {
    draw_set_color(c_black);
}

// Draw over the entire screen
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

// Reset color
draw_set_color(c_white);