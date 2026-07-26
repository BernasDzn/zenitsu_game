radius = 5;
alpha = 1;
max_radius = 120; // How far the explosion reaches

// Check for player damage immediately on spawn
if (instance_exists(o_player)) {
    if (point_distance(x, y, o_player.x, o_player.y) <= max_radius) {
        // DEAL HEAVY DAMAGE TO PLAYER
        if (o_player.hit_cooldown <= 0) {
            o_player.hp -= 15; // Bombs hurt a lot more!
            o_player.hit_cooldown = o_player.hit_cooldown_max;
            var _snd = audio_play_sound(choose(so_damage1,so_damage2), 1, false); 
            audio_sound_pitch(_snd, random_range(0.9, 1.1));
        }
    }
}

with (o_dummy) {
    // Check distance between the dummy and the shockwave (other.x, other.y)
    if (point_distance(x, y, other.x, other.y) <= other.max_radius) {
        hp -= 60; // Massive friendly fire damage
        hit_flash = 5;
        // --- ADD THIS EXPLOSION SCORE LOGIC ---
        global.player_score += 20;
        o_player.score_scale = 1.5; // Medium UI pop
        
        // Spawn a fiery orange popup
        var _popup = instance_create_depth(other.x, other.y - 40, other.depth - 50, o_score_popup);
        _popup.text = "+20";
        _popup.color = c_orange;
    }
}