x += vx;
vx *= 0.85; // Friction so the dust smoothly stops

life -= 1;
if (life <= 0) instance_destroy();