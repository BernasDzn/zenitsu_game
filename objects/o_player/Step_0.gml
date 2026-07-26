// --- 1. INPUTS ---
var key_down = keyboard_check(ord("S"));
var key_right = keyboard_check(ord("D"));
var key_left = keyboard_check(ord("A"));
var space = keyboard_check(vk_space);
// Toggle hitbox visibility with F1
if (keyboard_check_released(vk_f1)) {
    debug_hitboxes = !debug_hitboxes;
}

// --- UI JUICE LOGIC ---
// Smoothly interpolate the display score toward the actual score
if (display_score < global.player_score) {
    display_score = lerp(display_score, global.player_score, 0.15);
}

// Smoothly shrink the text scale back down to 1.0
score_scale = lerp(score_scale, 1.0, 0.1);

// ============================================================================
// --- GAME OVER STATE INTERCEPT ---
// ============================================================================
if (is_dead) {
    dead_timer++;
    hsp = 0;
    vsp = 0;
    image_speed = 0;
    
    // Press R to restart after dying
    if (keyboard_check_pressed(ord("R"))) {
        room_restart();
    }
    exit; // Stops the rest of the step event from running!
}

// ============================================================================
// --- HEALTH, I-FRAMES & REGEN ---
// ============================================================================
if (hit_cooldown > 0) {
    hit_cooldown -= 1;
    // Visually blink the player (transparency toggles every 4 frames)
    image_alpha = (hit_cooldown % 8 < 4) ? 0.3 : 1.0;
    image_blend = #FF6B6B;
} else {
    image_alpha = 1.0;
    image_blend = c_white;
}

// --- DELAYED REGENERATION LOGIC ---
// 1. Did we take damage? If our HP is lower than it was last frame, reset the delay!
if (hp < previous_hp) {
    regen_timer = regen_delay; 
}
// 2. Sync previous_hp for the next frame
previous_hp = hp; 

// 3. Count down the delay. If it reaches 0, start healing.
if (regen_timer > 0) {
    regen_timer -= 1;
} else if (hp > 0 && hp < hp_max) {
    hp += 0.05; // Fast enough to matter, slow enough to keep the pressure on
}

// --- DEATH TRIGGER ---
if (hp <= 0 && !is_dead) {
    is_dead = true;
    image_blend = c_dkgray; // Darken the player sprite to signify death
}

// ============================================================================
// DYNAMIC ENEMY SPAWNER
// ============================================================================

// 1. Define your scaling rules
var _start_delay = 180; // Base delay at 0 score (e.g., 3 seconds at 60fps)
var _min_delay = 60;    // The absolute fastest they can spawn (e.g., 0.5 seconds)
var _max_dummy = 25;

// Calculate current delay
var _current_delay = max(_min_delay, _start_delay - (global.player_score * 0.025));

// 2. Only run the spawner if the player is alive
if (!is_dead) {
    
    // Run the countdown
    enemy_spawn_timer -= 1;
    
    if (enemy_spawn_timer <= 0 && instance_number(o_dummy)<_max_dummy) {
        
        // Pick a random direction (left or right) and a far distance
        var _dir = choose(-1, 1);
        var _dist = irandom_range(700, 1000); 
        var _spawn_x = x + (_dir * _dist);
        
        // Clamp the spawn position to stay inside the room boundaries
        var _margin = 40; 
        _spawn_x = clamp(_spawn_x, _margin, room_width - _margin);
        
        // Ensure they actually spawned far enough away
        if (abs(_spawn_x - x) > 250) {
            
            // Spawn the dummy at the exact same Y level as the player
            instance_create_depth(_spawn_x, y, depth, o_dummy);
            
            // Reset the timer using the newly calculated dynamic delay!
            enemy_spawn_timer = _current_delay;
            
        } else {
            // If the wall forced them to spawn too close, abort and try again sooner
            enemy_spawn_timer = 1; 
        }
    }
}

#region Map Boundaries

// Clamp X to stay within the room (accounting for sprite width so they don't overlap the edge)
var _margin_x = abs(sprite_width / 2);
x = clamp(x, _margin_x, room_width - _margin_x);

// Clamp Y (if applicable for top-down or jumping mechanics)
var _margin_y = abs(sprite_height / 2);
y = clamp(y, _margin_y, room_height - _margin_y);

#endregion

// New Attack Inputs
var attack1_hold = mouse_check_button(mb_left);
var attack1_rel  = mouse_check_button_released(mb_left);
var attack2_hold = mouse_check_button(mb_right);
var attack2_rel  = mouse_check_button_released(mb_right);

var hmove = key_right - key_left;

// ============================================================================
// --- FIXED CHARGING DIRECTION ---
// ============================================================================
// Update facing direction immediately, even if crouching or charging an attack
if (hmove != 0) {
    // Only allow turning if we are NOT attacking, OR if we are in the charging phase (image_index 0)
    if (!is_attacking || (is_attacking && image_index == 0)) {
        last_h = hmove;
        image_xscale = last_h * 2; 
    }
}

// --- SPICE: HIT-STOP ---
if (freeze_frames > 0) {
    freeze_frames -= 1;
    image_speed = 0; // Freeze the animation perfectly in place
    exit; // Skips the entire rest of the Step Event! 
}

#region Attacks (State Machine)

// Start an attack if we are on the ground and not already attacking
if (!is_attacking && !crouch) {
    if (attack1_hold) {
        is_attacking = true;
        attack_type = 1;
        sprite_index = s_player_attack1;
        image_index = 0; 
        charge_timer = 0;
    } 
    else if (attack2_hold) {
        is_attacking = true;
        attack_type = 2;
        sprite_index = s_player_attack2;
        image_index = 0; 
        charge_timer = 0;
    }
}

// Handle the active attack
if (is_attacking) {
    hmove = 0; 
    image_speed = 0; 
    
    // --- 1. CHARGING PHASE ---
    if (image_index == 0) {
        // Build up charge while holding the button (capped at charge_max)
        if ((attack_type == 1 && attack1_hold) || (attack_type == 2 && attack2_hold)) {
            if (charge_timer < charge_max) {
                charge_timer += 1;
                
                // --- SPICE: Energy Vacuum ---
                // Spawn particles pulling inward once the charge gets going
                if (charge_timer > 10) {
                    // Calculate the exact vertical center of the player's collision mask
                    var _center_y = (bbox_top + bbox_bottom) / 2;
                    
                    // Pick a random angle and spawn distance
                    var _angle = random(360);
                    var _dist = random_range(40, 80);
                    
                    // Calculate starting coordinates around the true center
                    var _px = x + lengthdir_x(_dist, _angle);
                    var _py = _center_y + lengthdir_y(_dist, _angle);
                    
                    // Fire the particle in the exact opposite direction so it flies inward
                    part_type_direction(pt_energy, _angle + 180, _angle + 180, 0, 0);
                    part_type_speed(pt_energy, 5, 10, 0.2, 0); // Accelerates as it gets closer
                    part_type_life(pt_energy, 8, 12); // Dies right as it hits the center
                    
                    part_particles_create(global.sys_lightning, _px, _py, pt_energy, 1);
                }
                
                // --- SPICE: Max Charge Blink ---
                // Flash white on the exact frame it hits maximum power
                if (charge_timer == charge_max) {
                    attack_flash = 3; 
                }
            }
        }
        
        /// --- 2. RELEASE PHASE ---
        if ((attack_type == 1 && attack1_rel) || (attack_type == 2 && attack2_rel)) {
            image_index = 1; // Switch to the Strike frame
            attack_timer = 10;
            
            // Calculate charge percentage (0.0 to 1.0)
            var _charge_percent = charge_timer / charge_max;
            
            // Apply horizontal momentum (hsp) based on charge!
            if (attack_type == 1) {
                // Swipe: Base speed of 4, up to 10 at max charge
                accel_final = 4 + (6 * _charge_percent); 
                var _snd = audio_play_sound(so_slash, 1, false);
                audio_sound_pitch(_snd, random_range(0.85, 1.15));
            } else {
                // Poke: Base speed of 6, up to 15 at max charge
                accel_final = 6 + (9 * _charge_percent); 
                var _snd = audio_play_sound(so_stab, 1, false);
                audio_sound_pitch(_snd, random_range(0.85, 1.15));
            }
            
            // Force the momentum in the direction the player is facing
            last_h = sign(image_xscale);
        }
    }
    

    // --- 3. STRIKE PHASE ---
    if (image_index == 1) {
        attack_timer -= 1;
        
        // Calculate charge percentage (0.0 to 1.0)
        var _charge_percent = charge_timer / charge_max;
        
        var _range = 0;
        var _hit_y1 = bbox_top;
        var _hit_y2 = bbox_bottom;
        
        // --- DIFFERENTIATE ATTACK HITBOXES & CHARGE SCALING ---
        if (attack_type == 1) {
            // SWIPE: Shorter, wider arc (Base: 50px, Max Charge: 80px)
            _range = 100 + (30 * _charge_percent);
            _hit_y1 = bbox_top;       // Full body height
            _hit_y2 = bbox_bottom;
        } else {
            // POKE: Long, piercing thrust (Base: 70px, Max Charge: 120px)
            _range = 150 + (30 * _charge_percent);
            _hit_y1 = bbox_top + 10;  // Tighter vertical range (focused thrust)
            _hit_y2 = bbox_bottom - 10;
        }
        
        // Calculate horizontal bounds based on facing direction
        var _hit_x1 = (image_xscale > 0) ? x : x - _range;
        var _hit_x2 = (image_xscale > 0) ? x + _range : x;
        
        // --- SAVE FOR DEBUG DRAWING ---
        debug_box_x1 = _hit_x1;
        debug_box_x2 = _hit_x2;
        debug_box_y1 = _hit_y1;
        debug_box_y2 = _hit_y2;
        
        with (o_dummy) {
            if (collision_rectangle(_hit_x1, _hit_y1, _hit_x2, _hit_y2, id, false, false)) {
                if (hit_cooldown <= 0) {
                    // Deal damage based on attack type (Slash = 10, Stab = 15)
                    hp -= (other.attack_type == 1) ? 10 + 10 * _charge_percent : 15 + 15 * _charge_percent; 
                    hit_flash = 5;
                    hit_cooldown = 20; 
                    
                    // --- SIGN-SAFE RANDOM KNOCKBACK & BOUNCE ---
                    // Horizontal: Base speed of 6, plus 0 to 4 extra pixels, locked to facing direction
                    var _h_extra = irandom(5) + 2 * _charge_percent;
                    hsp = (10 + _h_extra) * sign(other.image_xscale); 
                    
                    // Vertical: Base launch of -3, plus 0 to 2 extra upward force (more negative = higher)
                    var _v_extra = irandom(2) + 1 * _charge_percent;
                    vsp = -6 - _v_extra;         
                    
                    bounce_count = 1; 
                    
                    other.freeze_frames += 2;
                    part_particles_create(global.sys_lightning, x, bbox_top + 15, other.pt_hit_spark, 10);
                }
            }
        }
        
        if (attack_timer <= 0) {
            is_attacking = false; 
            attack_type = 0;
        }
    }
}

#endregion

#region Movement

// Acceleration physics
if (hmove != 0) {
    if (last_h != hmove) {
        // --- SPICE: Turnaround Kick-up ---
        if (last_h != 0) {
            part_type_direction(pt_smoke, 45, 135, 0, 0); // Dust drifts upward slightly
            part_type_speed(pt_smoke, 1, 3, -0.1, 0);
            part_particles_create(sys_smoke, x, bbox_bottom, pt_smoke, 3);
            var _snd = audio_play_sound(so_brake, 1, false);
            audio_sound_pitch(_snd, random_range(0.9, 1.1));
        }
        
        last_h = hmove;
        accel_final = 0;
    }
    
    if (accel_final <= accel_max) {
        accel_final += accel;    
    }

    // When the timer hits our interval, play the sound!
    if (sprite_index == s_player_run && round(image_index) == 1 && round(image_index) != previous_frame) {
        // Play sound with a slight random pitch shift so it doesn't sound robotic
        var _pick = choose(so_step1, so_step2, so_step3, so_step4);
        var _snd = audio_play_sound(_pick, 1, false);
        audio_sound_pitch(_snd, random_range(0.9, 1.1));
    }
} else {
    // Because hmove is forced to 0 during an attack, this causes 
    // the player to naturally slide to a halt if they attack while running!
    if (accel_final > 0) {
        accel_final -= accel; 
        
        // --- SPICE: Skidding Dust ---
        // Random chance to spawn a tiny puff of smoke while sliding to a stop
        if (random(100) < 40) { 
            part_type_direction(pt_smoke, 45, 135, 0, 0);
            part_type_speed(pt_smoke, 0.5, 2, -0.1, 0);
            part_particles_create(sys_smoke, x, bbox_bottom, pt_smoke, 1); 
            var _snd = audio_play_sound(so_brake, 1, false);
            audio_sound_pitch(_snd, random_range(0.9, 1.1));
        }
    }
}

previous_frame = round(image_index);

if (accel_final < accel) {
    accel_final = 0;
    last_h = 0;
}

hsp = accel_final * last_h;

if (!crouch && hsp != 0) {
    x += hsp;
    y += vsp;
}

// Crouching logic
if (key_down && !is_attacking) {
    crouch = true;   
    hsp = 0;
} else {
    crouch = false;
}

#endregion

#region Animation

if (!is_attacking) {
    if (hmove != 0 && !crouch) {
        sprite_index = s_player_run;
    } else if (hmove == 0 && !crouch) {
        sprite_index = s_player_idle;
    } else if (crouch && hsp == 0) {
        sprite_index = s_player_crouch;
    }
    
    image_speed = 1; // Restore normal animation speed
}

// Flipping the sprite (Only turn if we actually press a key)
if (hmove > 0) image_xscale = 2;
if (hmove < 0) image_xscale = -2;

#endregion

#region Kutsuna Dash

if (hkrk_issen == true) {
    // FIXED: Changed hmove to last_h so you can dash in the direction you are facing
    if (crouch && last_h != 0 && !is_attacking) {
        if (space) {
            dash = true;    
            o_trail.reg = true;
        
            // --- 1. START SMOKE ---
            var _dir_back = (last_h == 1) ? 180 : 0; // FIXED hmove to last_h
            part_type_direction(pt_smoke, _dir_back - 25, _dir_back + 25, 0, 0);
            part_type_speed(pt_smoke, 4, 8, -0.2, 0); 
            part_particles_create(sys_smoke, x, bbox_bottom, pt_smoke, 15);
            
            var _number_copies = 10;
            for (var i = 0; i < _number_copies; i++) { 
                 // Calculate what percentage of the dash we are currently at (0.0 to 1.0)
                 var _fraction = i / _number_copies;
                 
                 // Find the exact X coordinate along the dash path (FIXED hmove to last_h)
                 var _spawn_x = x + (dash_distance * last_h * _fraction);
                 
                 var _ghost = instance_create_depth(_spawn_x, y, depth + 1, o_afterimage);
                 _ghost.sprite_index = sprite_index;
                 _ghost.image_index = image_index;
                 _ghost.image_xscale = image_xscale;
                 _ghost.image_yscale = image_yscale;
            }
            // Save our starting position before we move
            var _dash_start_x = x; 
            
            // Teleport (FIXED hmove to last_h)
            x += dash_distance * last_h;
            
            // --- SAVE FOR DEBUG DRAWING ---
            debug_dash_x1 = _dash_start_x;
            debug_dash_x2 = x;
            debug_dash_y1 = bbox_top;
            debug_dash_y2 = bbox_bottom;
            debug_dash_timer = 20; // Keep the dash box visible for 20 frames
            
            /// --- NEW: DASH AREA DAMAGE ---
            with (o_dummy) {
                if (collision_rectangle(_dash_start_x, other.bbox_top, other.x, other.bbox_bottom, id, false, false)) {
                    hp -= 50; 
                    hit_flash = 5;
                    hit_cooldown = 20;
                    
                    // --- SIGN-SAFE RANDOM KNOCKBACK & BOUNCE ---
                    // Horizontal: Base speed of 5, plus 0 to 4 extra pixels, locked to facing direction
                    var _h_extra = irandom(4);
                    hsp = (5 + _h_extra) * sign(other.image_xscale); 
                    
                    // Vertical: Base launch of -2, plus 0 to 2 extra upward force
                    var _v_extra = irandom(2);
                    vsp = -2 - _v_extra;         
                    
                    bounce_count = 2; 
                    
                    // Multi-Hit-Stop
                    other.freeze_frames += 3;
                    
                    // The Sparks
                    part_particles_create(global.sys_lightning, x, bbox_top + 15, other.pt_hit_spark, 20);
                    
                    // --- SPICE: ENEMY LIGHTNING BURST ---
                    var _bolt_count = irandom_range(1, 2); 
                    for (var i = 0; i < _bolt_count; i++) {
                        // Using completely unique variable names (_bx and _by) 
                        // so GameMaker knows these belong strictly to the Dummy!
                        var _bx = x + irandom_range(-20, 20);
                        var _by = y + irandom_range(-40, 0); 
                        
                        var _bolt = instance_create_depth(_bx, _by, depth + 1, o_kutsuna_lightning);
                        
                        // Blast the end of the bolt outward
                        _bolt.x2 = _bx + irandom_range(-70, 70);
                        _bolt.y2 = _by + irandom_range(-70, 70);
                        _bolt.drift_dir = choose(-1, 1);
                    }
                }
            }
            
            // play sound
            var _snd = audio_play_sound(so_thunder, 1, false);
            audio_sound_pitch(_snd, random_range(0.85, 1.15));
        
            // --- 2. END SMOKE ---
            var _dir_fwd = (last_h == 1) ? 0 : 180; // FIXED hmove to last_h
            part_type_direction(pt_smoke, _dir_fwd - 25, _dir_fwd + 25, 0, 0);
            part_type_speed(pt_smoke, 6, 12, -0.3, 0); 
            part_particles_create(sys_smoke, x, bbox_bottom, pt_smoke, 20);
        
            // --- 3. IMPACT FRAME ---
            instance_create_depth(0, 0, depth - 100, o_impact_frame);
        
            // --- 4. LIGHTNING ---
            var _bolt_count = irandom_range(3, 4);
            for (var i = 0; i < _bolt_count; i++) {
                var _spawn_offset = irandom_range(150, 300) + (i * 100); 
                var _start_x = x - (_spawn_offset * last_h); // FIXED hmove to last_h
            
                var _bolt = instance_create_depth(_start_x, bbox_bottom, depth + 1, o_kutsuna_lightning);
            
                var _strike_len = irandom_range(150, 350); 
                _bolt.x2 = _start_x + (_strike_len * last_h); // FIXED hmove to last_h
                _bolt.y2 = bbox_bottom; 
                _bolt.drift_dir = last_h; // FIXED hmove to last_h
            }

            crouch = false;
            alarm[0] = cooldown;
            hkrk_issen = false;
        }
    }
}

#endregion