function spears_shot (itemstack, player)
	local spear = itemstack:get_name() .. '_entity'
	local playerpos = player:getpos()
	local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, spear)
	local dir = player:get_look_dir()
	local sp = .14
	local dr = 0-- .2
	local gravity = 0--9.8
	obj:setvelocity({x=dir.x*sp, y=dir.y*sp, z=dir.z*sp})
	obj:setacceleration({x=-dir.x*dr, y=-gravity, z=-dir.z*dr})
	obj:setyaw(player:get_look_yaw()+math.pi)
	minetest.sound_play("spears_sound", {pos=playerpos})
	obj:get_luaentity().wear = itemstack:get_wear()
	return true
end
