if draw = true
{
	
	var left = dir == 1 ? 1 : 0;
	draw_sprite_stretched_ext(s_hkrk_issen,1,(reg_x - dist * left), y,dist,50,c_white,transparency)
	transparency = transparency * fade
	
}

//draw_sprite_stretched_ext(s_hkrk_issen,1,x,y,x+(4*o_player.dash_distance/5*sign(o_player.image_xscale)),50,c_white,transparency)