y += vsp;
vsp *= 0.85;       // Smoothly slow down the upward movement (friction)
alpha -= 0.02;     // Slowly fade out

// Destroy the object once it becomes completely invisible
if (alpha <= 0) {
    instance_destroy();
}