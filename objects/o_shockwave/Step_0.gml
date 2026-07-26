radius += 12;      // Expands aggressively fast
alpha -= 0.04;     // Fades out smoothly

if (alpha <= 0) {
    instance_destroy();
}