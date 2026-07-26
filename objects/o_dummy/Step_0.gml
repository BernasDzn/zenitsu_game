#region Map Boundaries

var _margin_x = abs(sprite_width / 2);
x = clamp(x, _margin_x, room_width - _margin_x);

var _margin_y = abs(sprite_height / 2);
y = clamp(y, _margin_y, room_height - _margin_y);

#endregion

// ============================================================================
// 1. AI BEHAVIOR LOGIC
// ============================================================================
if (instance_exists(o_player) && hp > 0) {
    var _dist = point_distance(x, y, o_player.x, y); 
    var _dir = sign(o_player.x - x);
    if (_dir == 0) _dir = 1; // Default facing if exactly on top of each other

    // --- JUMPER LOGIC ---
    if (enemy_type == "jumper") {
        if (state == "chase") {
            hsp = _dir * walk_speed;
            
            // If close enough and on the solid floor, prepare to jump!
            if (_dist < 200 && place_meeting(x, y + 1, o_ground)) { 
                state = "prepare_jump";
                jump_timer = 40; // Wait for about 2/3rds of a second before leaping
                hsp = 0;         // Stop walking completely
            }
        } 
        else if (state == "prepare_jump") {
            hsp = 0; // Ensure they stay still
            jump_timer -= 1;
            
            // Once the pause timer hits 0, launch the attack
            if (jump_timer <= 0) {
                state = "jump_attack";
                vsp = -8;            
                hsp = _dir * 6;     
            }
        }
        else if (state == "jump_attack") {
            // Check if we landed directly on the player
            if (place_meeting(x, y, o_player)) {
                
                if (o_player.hit_cooldown <= 0) {
                    o_player.hp -= 5;
                    o_player.hit_cooldown = o_player.hit_cooldown_max;
                    var _snd = audio_play_sound(choose(so_damage1,so_damage2), 1, false);
                    audio_sound_pitch(_snd, random_range(0.9, 1.1));
                    if(round(random_range(1,2))%2==0){
                        _snd = audio_play_sound(choose(so_monohit1,so_monohit2,so_monohit3), 1, false); 
                    }
                }
                
                state = "jump_back";
                vsp = -5;
                hsp = -_dir * 3.5; 
            }
            else if (place_meeting(x, y + 1, o_ground) && vsp >= 0) {
                state = "chase";
                hsp = 0; // Kill the momentum so they don't slide!
            }
        } 
        else if (state == "jump_back") {
            // Return to chasing once we land securely on the ground
            if (place_meeting(x, y + 1, o_ground) && vsp >= 0) {
                state = "chase";
            }
        }
    }
    
    // --- BOMBER LOGIC ---
    else if (enemy_type == "bomber") {
        if (state == "chase") {
            hsp = _dir * (walk_speed * 0.8); // Bombers walk slightly slower
            
            if (_dist < 90) {
                state = "fuse";
                hsp = 0; // Stop moving to plant the bomb
            }
        } 
        else if (state == "fuse") {
            fuse_timer -= 1;

            // Exponentially faster blinking
            var _blink_rate = max(2, (fuse_timer / fuse_time_max) * 15);
            blink_timer++;
            
            if (blink_timer >= _blink_rate) {
                blink_red = !blink_red;
                blink_timer = 0;
            }
            
            if(fuse_timer<=20 && played==false){
                var _snd = audio_play_sound(choose(so_monoexplode1,so_monoexplode2), 1, false); 
                played=true;
            }

            // Detonate!
            if (fuse_timer <= 0) {
                hp = 0; // Trigger the death logic below
            }
        }
    }
}

// ============================================================================
// 2. PHYSICS & COLLISION
// ============================================================================
vsp += grv; 

// Horizontal Collision
if (place_meeting(x + hsp, y, o_ground)) {
    while (!place_meeting(x + sign(hsp), y, o_ground)) {
        x += sign(hsp);
    }
    hsp = 0;
}
x += hsp; 

// Vertical Collision
if (place_meeting(x, y + vsp, o_ground)) {
    while (!place_meeting(x, y + sign(vsp), o_ground)) {
        y += sign(vsp);
    }
    
    if (bounce_count > 0 && vsp > 1) {
        vsp = -vsp * 0.5; 
        bounce_count -= 1;
    } else {
        // Only apply friction if we aren't being told to move by the AI
        if (state != "chase" && state != "jump_attack" && state != "jump_back") {
            vsp = 0;
            hsp *= 0.85; 
        } else if (state == "chase" || state == "fuse") {
            vsp = 0; // Keep flat on the ground
            hsp = min(hsp, walk_speed);
        }
    }
} else {
    y += vsp; // Apply gravity if we aren't touching the ground
}

// Hit sounds
if (hp != previous_hp && hp != 0) {
    var _pick = choose(so_hit1, so_hit2, so_hit3);
    var _snd = audio_play_sound(_pick, 1, false);
    audio_sound_pitch(_snd, random_range(0.9, 1.1));
    if(round(random_range(1,2))%2==0){
        _snd = audio_play_sound(choose(so_monodamage1,so_monodamage2,so_monodamage3,so_monodamage4,so_monodamage5), 1, false); 
    }
    state = "chase";
}

if (hit_cooldown > 0) hit_cooldown -= 1;
    
// ============================================================================
// SPRITE HANDLING & ANIMATION
// ============================================================================

if (state == "chase") {
    
    // Only play the walk animation if the dummy is actually covering ground!
    if (abs(hsp) > 0.1 && place_meeting(x, y + 1, o_ground)) {
        sprite_index = s_dummy_walk;
    } else {
        // If stuck against a wall in chase state, stand still
        sprite_index = s_dummy_idle; 
    }
    
} else {
    // For "prepare_jump", "jump_attack", or any other state, default to idle
    sprite_index = s_dummy_idle;
}

// ============================================================================
// 2.5 DAMAGE REACTIONS
// ============================================================================
if (hp < previous_hp) {
    
    // Check if the enemy is in the air (not touching the ground)
    if (!place_meeting(x, y + 1, o_ground)) {
        global.player_score += 5;
        o_player.score_scale = 1.3; // Give the UI a small pop
        
        // Spawn a cool pink/purple popup for the aerial juggle
        var _popup = instance_create_depth(x, y - 60, depth - 50, o_score_popup);
        _popup.text = "+5";
        _popup.color = c_fuchsia; 
    }
}

// Sync previous_hp for the next frame so we only detect the exact moment of impact
previous_hp = hp;

// ============================================================================
// 3. DEATH & EXPLOSIONS
// ============================================================================
if (hp <= 0) {
    
    // --- NEW SCORE LOGIC ---
    var _earned_points = false;

    if (enemy_type == "bomber" && fuse_timer <= 0) {
        if (previous_hp < hp_max) {
            _earned_points = true;
        }
    } else {
        _earned_points = true;
    }
    
    if (_earned_points) {
        global.player_score += 100;
        o_player.score_scale = 1.6; // Tell the UI to "pop" in size
        
        // Spawn the floating text slightly above the enemy
        var _popup = instance_create_depth(x, y - 40, depth - 50, o_score_popup);
        _popup.text = "+100";
    }
    
    // --- EXPLOSION VISUALS ---
    if (enemy_type == "bomber" && fuse_timer <= 0) {
        // 1. Color the smoke fiery orange and blast it hard
        part_type_color3(o_player.pt_smoke, c_yellow, c_orange, c_dkgray);
        part_type_direction(o_player.pt_smoke, 0, 360, 0, 0); 
        part_type_speed(o_player.pt_smoke, 6, 14, -0.4, 0); 
        part_type_size(o_player.pt_smoke, 0.8, 1.5, 0.02, 0); 
        
        part_particles_create(o_player.sys_smoke, x, y - 20, o_player.pt_smoke, 35); 
        
        // 2. Spawn the physical shockwave ring
        instance_create_depth(x, y - 20, depth - 10, o_shockwave);
        
        // 3. Reset smoke back to gray for normal player dashes
        part_type_color3(o_player.pt_smoke, c_silver, c_gray, c_dkgray);
        part_type_size(o_player.pt_smoke, 0.4, 0.8, 0.03, 0); 
        
    } else {
        // --- NORMAL DEATH SMOKE ---
        part_type_direction(o_player.pt_smoke, 0, 360, 0, 0);       
        part_type_speed(o_player.pt_smoke, 4, 10, -0.2, 0);         
        part_particles_create(o_player.sys_smoke, x, y - 20, o_player.pt_smoke, 25); 
    }
    
    var _snd = audio_play_sound(so_finish, 1, false); 
    audio_sound_pitch(_snd, random_range(0.9, 1.1));
    
    instance_destroy();
}