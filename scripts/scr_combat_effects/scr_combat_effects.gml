/// @function scr_trigger_impact(_x, _y)
/// @param {real} _x - The x coordinate of the hit
/// @param {real} _y - The y coordinate of the hit
function scr_trigger_impact(_x, _y) {
    // 1. Hit-Stop: Tell the game manager to freeze logic
    global.hit_stop = 4; // You must wrap your movement/animation code in `if (global.hit_stop <= 0)`
    
    // 2. Impact Frame: Flash the screen
    instance_create_depth(0, 0, -9999, o_impact_frame);
    
    // 3. Kutsuna Lightning: Spawn jagged bolts at the impact site
    instance_create_depth(_x, _y, depth - 10, o_kutsuna_lightning);
    
    // 4. Shockwave: Distort the background
    instance_create_depth(_x, _y, depth + 10, o_shockwave);
    
    // 5. Screen Shake: Tell the camera to vibrate violently
    if (instance_exists(o_camera)) {
        o_camera.shake_magnitude = 15;
        o_camera.shake_frames = 10;
    }
}