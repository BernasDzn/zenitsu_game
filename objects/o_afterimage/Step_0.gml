// Fade out rapidly
image_alpha -= 0.1;

// Destroy when invisible
if (image_alpha <= 0) {
    instance_destroy();
}