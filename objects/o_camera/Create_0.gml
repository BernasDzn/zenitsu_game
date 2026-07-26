#macro SMOOTHING 10

target = o_player;

xTo = x;
yTo = y;

// --- Capture Base Camera Size ---
base_cam_w = camera_get_view_width(view_camera[0]);
base_cam_h = camera_get_view_height(view_camera[0]);

// --- Smooth Zoom Variables ---
shake_magnitude = 0; 
shake_fade = 0.01;  // Needs to be very small since we are dealing in percentages now
shake_time = 0;