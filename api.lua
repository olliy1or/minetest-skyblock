--[[

SkyBlock for MineTest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

API FUNCTIONS

]]--



-- local variables
local last_start_id = 0
local start_positions = {}
local spawned_players = {}
local spawnpos = {}
local filename = minetest.get_worldpath()..'/skyblock'

-- debug
local dbg = function(message)
	if not skyblock.DEBUG then
		return
	end
	print("[SkyBlock] "..message)
end


--
-- PUBLIC FUNCTIONS
--


-- give inventory
skyblock.give_inventory = function(player)
	dbg("give_inventory() to "..player:get_player_name())
	player:get_inventory():add_item('main', 'default:tree')
	player:get_inventory():add_item('main', 'default:leaves 6')
	player:get_inventory():add_item('main', 'default:water_source 2')
	player:get_inventory():add_item('main', 'default:steel_ingot 3')
end


-- empty inventory
skyblock.empty_inventory = function(player)
	dbg("empty_inventory() from "..player:get_player_name())
	local inv = player:get_inventory()
	if not inv:is_empty("main") then
		for i=1,32 do
			inv:set_stack("main", i, nil)
		end
	end
	if not inv:is_empty("craft") then
		for i=1,9 do
			inv:set_stack("craft", i, nil)
		end
	end
end


-- get players spawn position
skyblock.get_spawn = function(player_name)
	local spawn = spawnpos[player_name]
	dbg("get_spawn() for "..player_name.." is "..dump(spawn))
	return spawn
end


-- set players spawn position
skyblock.set_spawn = function(player_name, pos)
	dbg("set_spawn() for "..player_name.." at "..dump(pos))
	spawnpos[player_name] = pos
	-- save the spawn data from the table to the file
	local output = io.open(filename..".spawn", "w")
	for i, v in pairs(spawnpos) do
		if v ~= nil then
			output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
		end
	end
	io.close(output)
end


-- get next spawn position using spiral matrix
skyblock.get_next_spawn = function()
	dbg("get_next_spawn()")
	last_start_id = last_start_id+1
	local output = io.open(filename..".last_start_id", "w")
	output:write(last_start_id)
	io.close(output)
	local spawn = start_positions[last_start_id]
	if spawn == nil then
		print("ERROR - no spawn position at id="..last_start_id)
	end
	return spawn
end


-- handle player spawn setup
skyblock.spawn_player = function(player)
	dbg("spawn_player() "..player:get_player_name())
	-- find the player spawn point
	local spawn = skyblock.get_spawn(player:get_player_name())
	if spawn == nil then
		spawn = skyblock.get_next_spawn()
		skyblock.set_spawn(player:get_player_name(),spawn)
	end
	local node = minetest.env:get_node(spawn)
	
	-- already has a spawn, teleport and return true 
	if node.name == "skyblock:spawn" then
		player:setpos({x=spawn.x,y=spawn.y+skyblock.SPAWN_HEIGHT,z=spawn.z})
		return true
	end

	-- add the start block and teleport the player
	skyblock.build_start_blocks(spawn)
	player:setpos({x=spawn.x,y=spawn.y+skyblock.SPAWN_HEIGHT,z=spawn.z})
end


-- build start block
skyblock.build_start_blocks = function(pos)
	dbg("build_start_blocks() at "..dump(pos))
	
	-- level 2 - air
	minetest.env:add_node({x=pos.x-1,y=pos.y+2,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x-1,y=pos.y+2,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x-1,y=pos.y+2,z=pos.z+1}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+2,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+2,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+2,z=pos.z+1}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+2,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+2,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+2,z=pos.z+1}, {name="air"})

	-- level 1 - air
	minetest.env:add_node({x=pos.x-1,y=pos.y+1,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x-1,y=pos.y+1,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x-1,y=pos.y+1,z=pos.z+1}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+1,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+1,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x,y=pos.y+1,z=pos.z+1}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+1,z=pos.z-1}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+1,z=pos.z}, {name="air"})
	minetest.env:add_node({x=pos.x+1,y=pos.y+1,z=pos.z+1}, {name="air"})

	-- level 0 - spawn and dirt with grass
	minetest.env:add_node({x=pos.x-1,y=pos.y,z=pos.z-1}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x-1,y=pos.y,z=pos.z}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x-1,y=pos.y,z=pos.z+1}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x,y=pos.y,z=pos.z-1}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x,y=pos.y,z=pos.z}, {name="skyblock:spawn"})
	minetest.env:add_node({x=pos.x,y=pos.y,z=pos.z+1}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x+1,y=pos.y,z=pos.z-1}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x+1,y=pos.y,z=pos.z}, {name="default:dirt_with_grass"})
	minetest.env:add_node({x=pos.x+1,y=pos.y,z=pos.z+1}, {name="default:dirt_with_grass"})

	-- level -1 - dirt and lava_source
	minetest.env:add_node({x=pos.x-1,y=pos.y-1,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x-1,y=pos.y-1,z=pos.z}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x-1,y=pos.y-1,z=pos.z+1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z}, {name="default:lava_source"})
	minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z+1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-1,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-1,z=pos.z}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-1,z=pos.z+1}, {name="default:dirt"})

	-- level -2 - dirt
	minetest.env:add_node({x=pos.x-1,y=pos.y-2,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x-1,y=pos.y-2,z=pos.z}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x-1,y=pos.y-2,z=pos.z+1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x,y=pos.y-2,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x,y=pos.y-2,z=pos.z}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x,y=pos.y-2,z=pos.z+1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-2,z=pos.z-1}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-2,z=pos.z}, {name="default:dirt"})
	minetest.env:add_node({x=pos.x+1,y=pos.y-2,z=pos.z+1}, {name="default:dirt"})

end


-- on_respawn
skyblock.on_respawnplayer = function(player)
	local player_name = player:get_player_name()
	local spawn = skyblock.get_spawn(player_name)
	dbg("on_respawnplayer() for "..player_name)

	-- unset old spawn position
	spawned_players[player_name] = nil
	skyblock.set_spawn(player_name, nil)
	skyblock.set_spawn(player_name.."_DEAD", spawn)
	
	-- set new spawn point and respawn
	skyblock.spawn_player(player)
	return true
end


-- globalstep for positioning
local spawn_timer = 0
skyblock.globalstep = function(dtime)
	spawn_timer = spawn_timer + dtime
	for k,player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		
		-- player has not spawned yet
		if spawned_players[player_name] == nil then

			-- handle new player spawn setup (no more than once per interval)
			if spawn_timer > skyblock.SPAWN_THROTLE then
				dbg("globalstep() new spawn for "..player_name.." (not spawned)")
				if skyblock.get_spawn(player:get_player_name()) or skyblock.spawn_player(player) then
					spawned_players[player:get_player_name()] = true
				end
			end

		-- player is spawned
		else
			local pos = player:getpos()

			-- hit the bottom, kill them (no more than once per interval)
			if spawn_timer > skyblock.SPAWN_THROTLE then
				if pos.y < skyblock.WORLD_BOTTOM then
					dbg("globalstep() "..player_name.." has fallen too far at "..dump(pos))
					skyblock.empty_inventory(player)
					player:set_hp(0)
					skyblock.give_inventory(player)
				end
			end
			
			-- walking on dirt_with_grass, change to dirt_with_grass_footsteps
			local np = {x=pos.x,y=pos.y-1,z=pos.z}
			if (minetest.env:get_node(np).name == "default:dirt_with_grass") then
				minetest.env:add_node(np, {name="default:dirt_with_grass_footsteps"})
			end
			
		end
		
	end
	
	-- reset the spawn_timer
	if spawn_timer > skyblock.SPAWN_THROTLE then	
		spawn_timer = 0
	end
end


-- make a tree
skyblock.generate_tree = function(pos)
	dbg("generate_tree() at "..dump(pos))
	
	-- check if we have space to make a tree
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.env:get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	
	local node = {name = ""}

	-- check if we should make an apple tree
	local is_apple_tree, is_jungle_tree = false, false
	if math.random(0, 8) == 0 then
		is_apple_tree = true
	else
		if math.random(0, 8) == 0 then
			is_jungle_tree = true
		end
	end
	
	-- add the tree
	if is_jungle_tree then
		node.name = "default:jungletree"
	else
		node.name = "default:tree"
	end
	for dy=0,4 do
		pos.y = pos.y+dy
		minetest.env:set_node(pos, node)
		pos.y = pos.y-dy
	end

	-- add leaves all around the tree
	pos.y = pos.y+3
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz

				-- check if we should add leaves or an apple
				if is_apple_tree and math.random(0, 6) == 0 then
					node.name = "default:apple"
				else
					node.name = "default:leaves"
				end
				
				-- add the leaves
				if dx == 0 and dz == 0 and dy==3 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.env:get_node(pos).name == "air" then
						minetest.env:set_node(pos, node)
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.env:set_node(pos, node)
						end
					end
				end

				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end



--
-- LOCAL FUNCTIONS
--


-- spiral matrix
-- http://rosettacode.org/wiki/Spiral_matrix#Lua
av, sn = math.abs, function(s) return s~=0 and s/av(s) or 0 end
local function sindex(y, x) -- returns the value at (x, y) in a spiral that starts at 1 and goes outwards
	if y == -x and y >= x then return (2*y+1)^2 end
	local l = math.max(av(y), av(x))
	return (2*l-1)^2+4*l+2*l*sn(x+y)+sn(y^2-x^2)*(l-(av(y)==l and sn(y)*x or sn(x)*y)) -- OH GOD WHAT
end
local function spiralt(side)
	local ret, id, start, stop = {}, 0, math.floor((-side+1)/2), math.floor((side-1)/2)
	for i = 1, side do
		for j = 1, side do
			local id = side^2 - sindex(stop - i + 1,start + j - 1)
			ret[id] = {x=i,z=j}
		end
	end
	return ret
end


-- reverse ipairs
function ripairs(t)
	local function ripairs_it(t,i)
		i=i-1
		local v=t[i]
		if v==nil then return v end
		return i,v
	end
	return ripairs_it, t, #t+1
end

 

--
-- INIT FUNCTIONS
--


-- load the spawn data from disk
local load_spawn = function()
    local input = io.open(filename..".spawn", "r")
    if input then
        while true do
            local x = input:read("*n")
            if x == nil then
                break
            end
            local y = input:read("*n")
            local z = input:read("*n")
            local name = input:read("*l")
            spawnpos[name:sub(2)] = {x = x, y = y, z = z}
        end
        io.close(input)
    else
        spawnpos = {}
    end
end
load_spawn() -- run it now


-- load the start positions from disk
local load_start_positions = function()
    local input = io.open(filename..".start_positions", "r")

	-- create start_positions file if needed
    if not input then
		local output = io.open(filename..".start_positions", "w")
		local pos
		for i,v in ripairs(spiralt(skyblock.WORLD_WIDTH)) do -- get positions using spiral
			pos = {x=v.x*skyblock.START_GAP, y=0, z=v.z*skyblock.START_GAP}
			output:write(pos.x.." "..pos.y.." "..pos.z.."\n")
		end
		io.close(output)
		input = io.open(filename..".start_positions", "r")
	end
	
	-- read start positions
	while true do
		local x = input:read("*n")
		if x == nil then
			break
		end
		local y = input:read("*n")
		local z = input:read("*n")
		table.insert(start_positions,{x = x, y = y, z = z})
	end
	io.close(input)
	
end
load_start_positions() -- run it now


-- load the last start position from disk
local load_last_start_id = function()
	local input = io.open(filename..".last_start_id", "r")
	
	-- create last_start_id file if needed
    if not input then
		local output = io.open(filename..".last_start_id", "w")
		output:write(last_start_id)
		io.close(output)
		input = io.open(filename..".last_start_id", "r")
	end
	
	-- read last start id
	last_start_id = input:read("*n")
	if last_start_id == nil then
		last_start_id = 0
	end
	io.close(input)
	
end
load_last_start_id() -- run it now