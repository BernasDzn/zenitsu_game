hp = 100;
hp_max = 100; 
hsp = 0;
vsp = 0;           
grv = 0.5;         
bounce_count = 0;  
hit_flash = 0;
hit_cooldown = 0;

previous_hp = hp_max;

// --- AI STATE MACHINE ---
enemy_type = choose("jumper", "bomber");
state = "chase"; 

// SLOWER WALK SPEED (Was 1.5 to 2.5)
walk_speed = random_range(0.8, 1.5); 
jump_timer = 0; // NEW: Tracks the pause before jumping

// Bomber Specific Variables
fuse_time_max = 90; 
fuse_timer = fuse_time_max;
blink_red = false;
blink_timer = 0;
played=false