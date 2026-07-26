if (!generated) return;
if (blink_timer > 0) return;

var _main_alpha = 1.0;
var _branch_alpha = 1.0;
var _main_thickness_mult = 1.0;

var _stage1_threshold = max_life * 0.9; 

var _stage2_threshold = max_life * 0.50; 

// --- CIRCUIT STAGES ---
if (life > _stage1_threshold) {

    _main_alpha = 1.0;
    _branch_alpha = 1.0;
    _main_thickness_mult = 1.0;
} 
else if (life > _stage2_threshold) {
    var _state2_duration = _stage1_threshold - _stage2_threshold;
    
    _main_alpha = 1.0;
    _branch_alpha = lerp(0, 1.0, (life - _stage2_threshold) / _state2_duration); 
    _main_thickness_mult = 1.6; 
} 
else {
    _main_alpha = life / _stage2_threshold; 
    _branch_alpha = 0;
    _main_thickness_mult = _main_alpha; 
}

// Hard strobe on the main bolt during the Dissipation stage
// (Using % 4 < 2 so it blinks at that chunky 1/24th second anime timing)
if (life <= _stage2_threshold && (life % 4 < 2)) {
    _main_alpha = 0;
}

var _base_thick = 1 * _main_thickness_mult; 

gpu_set_blendmode(bm_add);
draw_set_color(c_orange);

// --- DRAW BRANCHES (Only if circuit is open) ---
if (_branch_alpha > 0) {
    for (var i = 0; i < branch_count; i++) {
        var _joint = branch_joint[i];
        var px = current_x[_joint]; 
        var py = current_y[_joint];
        var ex = px + branch_cx[i]; 
        var ey = py + branch_cy[i];
        
        var _b_thick = max((_base_thick * 0.4) + 2, 2); 
        
        draw_set_alpha(0.3 * _branch_alpha);
        draw_line_width(px, py, ex, ey, _b_thick * 3.5);
        draw_circle(ex, ey, (_b_thick * 3.5) / 2, false);
        
        draw_set_alpha(0.7 * _branch_alpha);
        draw_line_width(px, py, ex, ey, _b_thick * 1.5);
        draw_circle(ex, ey, (_b_thick * 1.5) / 2, false);
		// --- DRAW Y-FORK GLOW ---
        if (branch_has_fork[i]) {
            var fx1 = ex + branch_f1_x[i]; var fy1 = ey + branch_f1_y[i];
            var fx2 = ex + branch_f2_x[i]; var fy2 = ey + branch_f2_y[i];
            var _f_thick = _b_thick * 0.7; // Forks are slightly thinner
            
            draw_set_alpha(0.3 * _branch_alpha);
            draw_line_width(ex, ey, fx1, fy1, _f_thick * 3.5);
            draw_circle(fx1, fy1, (_f_thick * 3.5) / 2, false);
            draw_line_width(ex, ey, fx2, fy2, _f_thick * 3.5);
            draw_circle(fx2, fy2, (_f_thick * 3.5) / 2, false);
            
            draw_set_alpha(0.7 * _branch_alpha);
            draw_line_width(ex, ey, fx1, fy1, _f_thick * 1.5);
            draw_circle(fx1, fy1, (_f_thick * 1.5) / 2, false);
            draw_line_width(ex, ey, fx2, fy2, _f_thick * 1.5);
            draw_circle(fx2, fy2, (_f_thick * 1.5) / 2, false);
        }
    }
}

// --- DRAW MAIN BOLT GLOW ---
if (_main_alpha > 0) {
    for (var i = 0; i < segments; i++) {
        var _thick = max(_base_thick + 2, 2); 
        var _glow_w = _thick * 3.5; 
        
        draw_set_alpha(0.3 * _main_alpha);
        draw_line_width(current_x[i], current_y[i], current_x[i+1], current_y[i+1], _glow_w);
        draw_circle(current_x[i], current_y[i], _glow_w / 2, false);
        draw_circle(current_x[i+1], current_y[i+1], _glow_w / 2, false);
        
        draw_set_alpha(0.7 * _main_alpha);
        draw_line_width(current_x[i], current_y[i], current_x[i+1], current_y[i+1], _thick * 1.5);
        draw_circle(current_x[i], current_y[i], (_thick * 1.5) / 2, false);
        draw_circle(current_x[i+1], current_y[i+1], (_thick * 1.5) / 2, false);
    }
}

gpu_set_blendmode(bm_normal);
draw_set_color(c_white);

// --- DRAW BRANCH CORES ---
if (_branch_alpha > 0) {
    for (var i = 0; i < branch_count; i++) {
        var _joint = branch_joint[i];
        var px = current_x[_joint]; 
        var py = current_y[_joint];
        var ex = px + branch_cx[i]; 
        var ey = py + branch_cy[i];
        var _bc_w = max(_base_thick * 0.2, 1);
        
        draw_set_alpha(_branch_alpha);
        draw_line_width(px, py, ex, ey, _bc_w);
        draw_circle(ex, ey, _bc_w / 2, false);
		// --- DRAW Y-FORK CORE ---
        if (branch_has_fork[i]) {
            var fx1 = ex + branch_f1_x[i]; var fy1 = ey + branch_f1_y[i];
            var fx2 = ex + branch_f2_x[i]; var fy2 = ey + branch_f2_y[i];
            var _fc_w = max(_bc_w * 0.7, 1);
            
            draw_line_width(ex, ey, fx1, fy1, _fc_w);
            draw_circle(fx1, fy1, _fc_w / 2, false);
            draw_line_width(ex, ey, fx2, fy2, _fc_w);
            draw_circle(fx2, fy2, _fc_w / 2, false);
        }
    }
}

// --- DRAW MAIN BOLT CORE ---
if (_main_alpha > 0) {
    draw_set_alpha(_main_alpha);
    for (var i = 0; i < segments; i++) {
        var _core_w = max(_base_thick * 0.4, 2);
        draw_line_width(current_x[i], current_y[i], current_x[i+1], current_y[i+1], _core_w);
        draw_circle(current_x[i], current_y[i], _core_w / 2, false);
        draw_circle(current_x[i+1], current_y[i+1], _core_w / 2, false);
    }
}

draw_set_alpha(1.0);