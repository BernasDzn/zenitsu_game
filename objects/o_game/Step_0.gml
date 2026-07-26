// Keep your dynamic breathing wave for the filter cutoff
ambient_timer += 0.008; 
ambient_filter.cutoff = 375 + (sin(ambient_timer) * 50);