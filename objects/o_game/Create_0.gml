ambient_bus = audio_bus_create();

// 1. Low-Pass Filter (Index 0)
ambient_filter = audio_effect_create(AudioEffectType.LPF2);
ambient_filter.cutoff = 350; 
ambient_bus.effects[0] = ambient_filter;

// 2. Delay / Echo Effect (Index 1)
ambient_delay = audio_effect_create(AudioEffectType.Delay);
ambient_delay.time = 0.5;     // Delay time in seconds (e.g., half-second gap)
ambient_delay.feedback = 0.4; // How much the echo repeats (0 = single echo, 1 = endless loop)
ambient_delay.mix = 0.3;      // Wet/dry mix balance (0 = no echo, 1 = 100% echo)
ambient_bus.effects[1] = ambient_delay;

// 3. Emitter and playback setup
ambient_emitter = audio_emitter_create();
audio_emitter_bus(ambient_emitter, ambient_bus);

ambient_instance = audio_play_sound_on(ambient_emitter, so_whitenoise, true, 1);
audio_sound_gain(ambient_instance, 1, 0);

ambient_timer = 0;