x2 = x;
y2 = y;
generated = false;

max_life = 30; 
life = max_life;
timer = 0;

segments = irandom_range(10, 20); 
drift_dir = 1;

// Vastly different speeds per bolt (some sluggish, some violently fast)
drift_speed = random_range(60, 120); 

base_x = array_create(segments + 1);
base_y = array_create(segments + 1);
current_x = array_create(segments + 1);
current_y = array_create(segments + 1);
target_x = array_create(segments + 1);
target_y = array_create(segments + 1);

// Array to hold dynamic branches
branch_count = 0; // Standard integer counter instead of array_length

blink_timer = 0;