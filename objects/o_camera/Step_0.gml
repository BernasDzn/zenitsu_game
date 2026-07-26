// Normal camera behaviour (Tracking)
if (target != noone and instance_exists(target)) {
    xTo = target.x;
    yTo = target.y;
}

x += (xTo - x) / SMOOTHING;
y += (yTo - y) / SMOOTHING;

// --- The Zoom Shake Math ---
var _zoom_multiplier = 1.0; // 1.0 is default size (100%)

if (shake_magnitude > 0) {
    // Advance the wave (Controls how fast it pulses in and out)
    shake_time += 0.5; 
    
    // Calculate the zoom factor. We subtract it from 1.0 so a positive magnitude zooms IN (makes view smaller).
    _zoom_multiplier = 1.0 - (sin(shake_time) * shake_magnitude);
    
    // Smoothly fade the zoom effect back to 0
    shake_magnitude = max(0, shake_magnitude - shake_fade); 
} else {
    shake_time = 0; 
}

// --- Apply the Zoom to the Camera Size ---
var _current_w = base_cam_w * _zoom_multiplier;
var _current_h = base_cam_h * _zoom_multiplier;

camera_set_view_size(view_camera[0], _current_w, _current_h);

// --- Apply Everything to the View ---
// We center the coordinates based on the NEW dynamically sized width and height
var _final_x = x - (_current_w / 2);
var _final_y = y - (_current_h / 2);

// Clamp the camera so zooming out doesn't reveal the gray space outside the map
_final_x = clamp(_final_x, 0, room_width - _current_w);
_final_y = clamp(_final_y, 0, room_height - _current_h);

camera_set_view_pos(view_camera[0], _final_x, _final_y);