function spears_register_spear(kind, desc, eq, toughness, craft)

	minetest.register_tool("spears:spear_" .. kind, {
		description = desc .. " spear",
		inventory_image = "spears_spear_" .. kind .. ".png",
		wield_scale= {x=2,y=1,z=1},
		on_drop = function(itemstack, user, pointed_thing)
			spears_shot(itemstack, user)
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
		on_place = function(itemstack, user, pointed_thing)
			minetest.add_item(pointed_thing.above, itemstack)
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
		tool_capabilities = {
			full_punch_interval = 1.5,
			max_drop_level=1,
			groupcaps={
				cracky = {times={[3]=2}, uses=toughness, maxlevel=1},
			},
			damage_groups = {fleshy=eq},
		}
	})
	
	local SPEAR_ENTITY={
		physical = false,
		timer=0,
		visual = "wielditem",
		visual_size = {x=0.15, y=0.1},
		textures = {"spears:spear_" .. kind},
		lastpos={},
		collisionbox = {0,0,0,0,0,0},
		on_punch = function(self, puncher)
			if puncher then
				if puncher:is_player() then
					local stack = {name='spears:spear_' .. kind, wear=self.wear+65535/toughness}
					local inv = puncher:get_inventory()
					if inv:room_for_item("main", stack) then
						inv:add_item("main", stack)
						self.object:remove()
					end
				end
			end
		end,
	}
	
	SPEAR_ENTITY.on_step = function(self, dtime)
		self.timer=self.timer+dtime
		local pos = self.object:getpos()
		local node = minetest.get_node(pos)
		if not self.wear then
			self.object:remove()
			return
		end
		
		if self.lastpos.x~=nil then
			if node.name ~= "air" and not (string.find(node.name, 'grass') and not string.find(node.name, 'dirt')) and not string.find(node.name, 'flowers:') and not string.find(node.name, 'farming:') then
				self.object:remove()
				minetest.add_item(self.lastpos, {name='spears:spear_' .. kind, wear=self.wear+65535/toughness})
			elseif self.timer>0.2 then
				local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1)
				for k, obj in pairs(objs) do
					if obj:get_luaentity() ~= nil then
						if obj:get_luaentity().name ~= "spears:spear_" .. kind .. "_entity" and obj:get_luaentity().name ~= "__builtin:item" then
							local speed = vector.length(self.object:getvelocity())
							local damage = (speed + eq)^1.12-20
							obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=damage},
							}, nil)
							self.object:remove()
							minetest.add_item(self.lastpos, {name='spears:spear_' .. kind, wear=self.wear+65535/toughness})
						end
					end
				end
			end
		end
		self.lastpos={x=pos.x, y=pos.y, z=pos.z}
	end
	
	minetest.register_entity("spears:spear_" .. kind .. "_entity", SPEAR_ENTITY)
	
	minetest.register_craft({
		output = 'spears:spear_' .. kind .. ' 4',
		recipe = {
			{'group:wood', 'group:wood', craft},
		}
	})
	
	minetest.register_craft({
		output = 'spears:spear_' .. kind .. ' 4',
		recipe = {
			{craft, 'group:wood', 'group:wood'},
		}
	})
end

if not DISABLE_STONE_SPEAR then
	spears_register_spear('stone', 'Stone', 4, 20, 'group:stone')
end

if not DISABLE_STEEL_SPEAR then
	spears_register_spear('steel', 'Steel', 6, 30, 'default:steel_ingot')
end

if not DISABLE_OBSIDIAN_SPEAR then
	spears_register_spear('obsidian', 'Obsidian', 8, 30, 'default:obsidian')
end

if not DISABLE_DIAMOND_SPEAR then
	spears_register_spear('diamond', 'Diamond', 8, 40, 'default:diamond')
end
