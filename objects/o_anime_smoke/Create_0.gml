max_life = 20;
life = max_life;
vx = 0; 

blob_count = irandom_range(5, 8); 

// --- NEW: Master Size Control ---
// 1.0 is your original size. 0.5 is exactly half-size. 
var _size_mult = 0.5; 

// Use classic 1D arrays instead of structs
for(var i = 0; i < blob_count; i++) {
    // We multiply the offsets by the multiplier so the grouping stays tight
    blob_ox[i] = random_range(-25, 25) * _size_mult;
    blob_oy[i] = random_range(-20, 5) * _size_mult; 
    
    // We multiply the max radius so the blobs themselves are smaller
    blob_max_r[i] = random_range(15, 35) * _size_mult;
}