

function spears_shot (itemstack, player)
	local spear = itemstack:get_name() .. '_entity'
	local playerpos = player:getpos()
	local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, spear)
	local dir = player:get_look_dir()
	obj:setvelocity({x=dir.x*14, y=dir.y*14, z=dir.z*14})
	obj:setacceleration({x=-dir.x*.5, y=-9.8, z=-dir.z*.5})
	obj:setyaw(player:get_look_yaw()+math.pi)
	minetest.sound_play("spears_sound", {pos=playerpos})
	obj:get_luaentity().wear = itemstack:get_wear()
	return true
end
