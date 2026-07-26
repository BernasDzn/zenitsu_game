if (blink_timer > 0) {
    blink_timer -= 1;
} else if (random(100) < 10) {
    // 10% chance to blink. Holds the blink for 2 frames (~1/30th to 1/24th of a sec)
    blink_timer = 2; 
}

if (!generated) {
    var _dist = point_distance(x, y, x2, y2);
    var _dir = point_direction(x, y, x2, y2);
    var _seg_len = _dist / segments;
    
    // Bring back the arch height and the wave distortion
    var _arc_height = irandom_range(60, 140); 
    var _wave_freq = random_range(1.5, 3.5); 
    
    for (var i = 0; i <= segments; i++) {
        var _percent = i / segments;
        
        // Build the positions angled toward the target
        var _bx = x + lengthdir_x(_seg_len * i, _dir);
        var _by = y + lengthdir_y(_seg_len * i, _dir);
        
        // Apply the flowing arch AND the distortion so it's not a perfect circle
        var _arch = sin(_percent * pi) * _arc_height;
        var _distortion = sin(_percent * pi * _wave_freq) * irandom_range(10, 30);
        
        _by -= (_arch + _distortion);
        
        base_x[i] = _bx; base_y[i] = _by;
        current_x[i] = _bx; current_y[i] = _by;
        target_x[i] = _bx; target_y[i] = _by;
        
        // Spawn Branches (Keeping your capped length)
        // Spawn Branches (Lowered to 35% chance so it doesn't clutter every joint)
		if (i > 0 && i < segments && random(100) < 35) { 
		    var _max_branch_len = 65; 
		    var _b_len = min(random_range(30, 90), _max_branch_len);
		    var _b_ang = _dir + choose(-1, 1) * irandom_range(20, 80);
    
		    branch_joint[branch_count] = i;
		    branch_bx[branch_count] = lengthdir_x(_b_len, _b_ang);
		    branch_by[branch_count] = lengthdir_y(_b_len, _b_ang);
		    branch_cx[branch_count] = branch_bx[branch_count];
		    branch_cy[branch_count] = branch_by[branch_count];
		    branch_tx[branch_count] = branch_bx[branch_count];
		    branch_ty[branch_count] = branch_by[branch_count];
    
		    // --- NEW: Y-FORK LOGIC ---
		    // 75% chance that this branch splits into two smaller tips
		    if (random(100) < 75) {
		        branch_has_fork[branch_count] = true;
		        var _f_len = _b_len * random_range(0.4, 0.7); // Forks are shorter than the stem
        
		        branch_f1_x[branch_count] = lengthdir_x(_f_len, _b_ang + irandom_range(15, 45));
		        branch_f1_y[branch_count] = lengthdir_y(_f_len, _b_ang + irandom_range(15, 45));
		        branch_f2_x[branch_count] = lengthdir_x(_f_len, _b_ang - irandom_range(15, 45));
		        branch_f2_y[branch_count] = lengthdir_y(_f_len, _b_ang - irandom_range(15, 45));
		    } else {
		        branch_has_fork[branch_count] = false;
		    }
    
		    branch_count++;
		}
    }
    generated = true;
}

timer -= 1;
if (timer <= 0) {
    timer = irandom_range(2, 4); 
    var _dir = point_direction(x, y, x2, y2);
    var _nx = lengthdir_x(1, _dir + 90);
    var _ny = lengthdir_y(1, _dir + 90);
    
    for (var i = 1; i < segments; i++) {
        var _offset = choose(-1, 1) * irandom_range(10, 30);
        target_x[i] = base_x[i] + (_nx * _offset);
        target_y[i] = base_y[i] + (_ny * _offset);
    }
    target_x[segments] = base_x[segments] + irandom_range(-20, 20);
    target_y[segments] = y2; 
    
    for (var i = 0; i < branch_count; i++) {
        branch_tx[i] = branch_bx[i] + irandom_range(-25, 25);
        branch_ty[i] = branch_by[i] + irandom_range(-25, 25);
    }
}

for (var i = 1; i <= segments; i++) {
    current_x[i] = lerp(current_x[i], target_x[i], 0.5);
    current_y[i] = lerp(current_y[i], target_y[i], 0.5);
}
for (var i = 0; i < branch_count; i++) {
    branch_cx[i] = lerp(branch_cx[i], branch_tx[i], 0.5);
    branch_cy[i] = lerp(branch_cy[i], branch_ty[i], 0.5);
}

for (var i = 0; i <= segments; i++) {
    base_x[i] += drift_speed * drift_dir;
    target_x[i] += drift_speed * drift_dir;
    current_x[i] += drift_speed * drift_dir;
}
drift_speed = lerp(drift_speed, 0, 0.5); // Braking friction

life -= 1;
if (life <= 0) instance_destroy();