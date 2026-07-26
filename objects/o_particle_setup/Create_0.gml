
particle_System = part_system_create();


particle_Dust = part_type_create();


part_type_sprite(particle_Dust, s_dust, 0, 0, 1);
part_type_size(particle_Dust,1,1.5,0.001,0);

part_type_direction(particle_Dust,0,359,0,1)
part_type_speed(particle_Dust,0.1,0.2,-0.004,0)

part_type_life(particle_Dust,50,70)

part_type_orientation(particle_Dust,0,359,0.1,1,0)

part_type_alpha3(particle_Dust,0.1,0.2,0.01)
