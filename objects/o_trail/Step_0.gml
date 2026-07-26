if !draw
{
	x = o_player.x;
	y = o_player.y-o_player.sprite_height/2;
}

dist = o_player.dash_distance;

if reg = true
{
	reg_x = o_player.x;
	dir = o_player.image_xscale / 2;
	reg = false
	draw=true;
}
