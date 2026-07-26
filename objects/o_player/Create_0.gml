debug_hitboxes = false;
debug_box_x1 = 0; debug_box_x2 = 0; debug_box_y1 = 0; debug_box_y2 = 0;
debug_dash_x1 = 0; debug_dash_x2 = 0; debug_dash_y1 = 0; debug_dash_y2 = 0;
debug_dash_timer = 0;

dash = false
mask_index = s_player_idle;

cooldown = 150
hkrk_issen = true
dash_distance = room_width/3

// --- Player Stats & Health ---
hp_max = 100;
hp = hp_max;

hit_cooldown = 0; // Tracks i-frames so you don't take constant damage
hit_cooldown_max = 60; // 1 second of invulnerability after being hit

// --- Game Loop Variables ---
global.player_score = 0;
is_dead = false;
dead_timer = 0;

enemy_spawn_timer = 300; // Start with a 2-second delay before the first enemy appears
// --- Delayed Regen Variables ---
regen_delay = 300; // Wait 3 seconds (180 frames at 60fps) after getting hit to start healing
regen_timer = 0;   // The actual countdown timer
previous_hp = hp;  // Helps the player realize when they've been hurt

// --- UI Animation Variables ---
display_score = 0; // The score currently drawn on screen (will chase global.player_score)
score_scale = 1.0; // The size multiplier for the text

crouch = 0

accel = 0.75
accel_final = 0
accel_max = 6
last_h = 0
hsp = 0
vsp = 0

attack = false
attack_flash = 0;

is_attacking = false;
attack_type = 0;
attack_timer = 0;

freeze_frames = 0;

// --- Attack Charging ---
charge_timer = 0;
charge_max = 45; // How many frames it takes to reach max charge (45 = 0.75 seconds)
previous_frame = 0;

// --- UI Animation Variables ---
ui_flash_alpha = 0;
ui_bar_scale_y = 1;
ui_was_charging = false;


// --- Lightning Particle Setup ---
global.sys_lightning = part_system_create();
part_system_depth(global.sys_lightning, depth - 1); // Draws slightly in front of the player

global.pt_lightning = part_type_create();

// Use a built-in spark shape (we'll cover custom Kutsuna sprites below)
part_type_shape(global.pt_lightning, pt_shape_spark); 

// Visuals: Start white (hot core), turn yellow, fade to orange
part_type_color3(global.pt_lightning, c_white, c_yellow, c_orange);
part_type_alpha3(global.pt_lightning, 1, 1, 0); 
part_type_blend(global.pt_lightning, true); // Additive blending for an electric glow

// Movement: Burst out fast, slow down quickly, wiggle erratically
part_type_size(global.pt_lightning, 0.5, 1.2, -0.05, 0.2); 
part_type_speed(global.pt_lightning, 3, 8, -0.2, 0); 
part_type_direction(global.pt_lightning, 0, 359, 0, 45); // Random directions with high wiggle
part_type_orientation(global.pt_lightning, 0, 359, 0, 0, true);

// Lifespan: Very quick flashes (15 to 25 steps)
part_type_life(global.pt_lightning, 15, 25);

// --- REALISTIC SMOKE PARTICLES ---
sys_smoke = part_system_create();
part_system_depth(sys_smoke, depth - 5); // Draw slightly in front of player

pt_smoke = part_type_create();
part_type_shape(pt_smoke, pt_shape_smoke); // Built-in realistic smoke texture
part_type_size(pt_smoke, 0.4, 0.8, 0.03, 0); // Starts medium, expands outwards
part_type_color3(pt_smoke, c_silver, c_gray, c_dkgray); 
part_type_alpha3(pt_smoke, 0.7, 0.4, 0);
part_type_orientation(pt_smoke, 0, 360, 2, 0, false); // Slowly spins
part_type_life(pt_smoke, 25, 40);

pt_hit_spark = part_type_create();
part_type_shape(pt_hit_spark, pt_shape_line);
part_type_size(pt_hit_spark, 0.1, 0.4, -0.02, 0); // Shrinks over time
part_type_color2(pt_hit_spark, c_white, c_yellow); // White hot to yellow
part_type_speed(pt_hit_spark, 12, 22, -0.8, 0); // Extremely fast, heavy friction
part_type_direction(pt_hit_spark, 0, 360, 0, 0);
part_type_orientation(pt_hit_spark, 0, 360, 0, 0, 1);
part_type_life(pt_hit_spark, 20, 35); // Lives long enough to see!

pt_energy = part_type_create();
part_type_shape(pt_energy, pt_shape_spark);
part_type_color2(pt_energy, c_white, c_aqua); // Starts white, fades to blue
part_type_size(pt_energy, 0.05, 0.15, -0.005, 0); // Very tiny slivers
part_type_blend(pt_energy, true);


_x1 = infinity;
_x2 = -infinity;
_y1 = infinity;
_y2 = -infinity;

// --- GRAVITY & JUMPING ---
grv = 0.4;       // How fast the player falls
jspd = -10;      // Jump strength (negative is UP in GameMaker)

// --- COMBAT DASH ---
is_dashing = false;
dash_spd = 18;
dash_timer = 0;
dash_cooldown = 0;

// --- DYNAMIC RENDERING ---
draw_scale_x = 1.0;
draw_scale_y = 1.0;
afterimage_timer = 0;
ui_glitch_frames = 0;
scale_x_spd = 0;
scale_y_spd = 0;