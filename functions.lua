function spears_shot (itemstack, player)
	local spear = itemstack:get_name() .. '_entity'
	local playerpos = player:getpos()
	local spear_object = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, spear)
	local direction = player:get_look_dir()
	local pitch = player:get_look_vertical()
	local yaw = player:get_look_horizontal()
	local throw_speed = 15
	local drag = 0.3
	local gravity = 9.8
	spear_object:set_velocity({x = direction.x*throw_speed, y = direction.y*throw_speed, z = direction.z*throw_speed})
	spear_object:set_acceleration({x = -direction.x*drag, y = -gravity, z = -direction.z*drag})
	spear_object:set_rotation({x = 0, y = yaw + math.pi/2, z = pitch + math.pi/6})
	minetest.sound_play("spears_throw", {pos = playerpos}, true)
	spear_object:get_luaentity()._wear = itemstack:get_wear()
	return true
end

function spears_set_entity(spear_type, base_damage, toughness)
	local SPEAR_ENTITY={
		initial_properties = {
			physical = false,
			visual = "item",
			visual_size = {x = 0.3, y = 0.3, z = 0.3},
			wield_item = "spears:spear_" .. spear_type,
			collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},

		on_punch = function(self, puncher)
			if puncher:is_player() then
				local stack = {name='spears:spear_' .. spear_type, wear = self._wear}
				local inv = puncher:get_inventory()
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
					self.object:remove()
				end
			end
		end,

		on_step = function(self, dtime)
			if not self._wear then
				self.object:remove()
				return
			end
			local acceleration = self.object:get_acceleration()
			local velocity = self.object:get_velocity()
			local speed = vector.length(velocity)
			local yaw = minetest.dir_to_yaw(velocity)
			local pitch = math.acos(velocity.y/speed) - math.pi/3
			local pos = vector.add(self.object:get_pos(), vector.multiply(velocity, dtime))
			local node = minetest.get_node(pos)
			if speed > 0 then
				if node.name ~= "air" and minetest.get_item_group(node.name, 'attached_node') < 1 then
					self.object:set_acceleration({x = 0, y = 0, z = 0})
					self.object:set_velocity({x = 0, y = 0, z = 0})
					minetest.sound_play("default_place_node.2", {pos = pos}, true)
					self._wear = self._wear + 65535/toughness
					if self._wear >= 65535 then
						self.object:remove()
						return
					end
				else
					self.object:set_rotation({x = 0, y = yaw + math.pi/2, z = pitch})
					local objects_in_radius = minetest.get_objects_inside_radius(pos, 1)
					for _,object in ipairs(objects_in_radius) do
						if object:is_player() or (object:get_luaentity().name ~= self.name and object:get_luaentity().name ~= "_builtin:item") then
							local direction = vector.normalize(velocity)
							local damage = (speed + base_damage)^1.15-20
							object:punch(self.object, 1.0, {full_punch_interval = 1.0, damage_groups = {fleshy=damage},}, direction)
							self.object:remove()
							minetest.sound_play("spears_hit", {pos = pos}, true)
							if self._wear + 65535/toughness < 65535 then
								minetest.add_item(pos, {name='spears:spear_' .. spear_type, wear = self._wear + 65535/toughness})
							end
						end
					end
				end
			end
		end,
	}
	return SPEAR_ENTITY
end
