worldlayers = {}

local layers = {} -- localize to make use simpler and faster in the code
worldlayers.registered_layers = layers

function worldlayers.register_layer(layer)
	local size = layer.ymax - layer.ymin
	for i, old_layer in ipairs(layers) do
		if old_layer.ymax - old_layer.ymin > size then
			table.insert(layers, i, layer)
			return
		end
	end
	table.insert(layers, layer)
end

function worldlayers.iter(pos)
	local y = pos.y
	local n = 1
	return function()
		for i=n, #layers do
			local layer = layers[i]
			if y >= layer.ymin and y <= layer.ymax then
				n = i+1
				return i, layer
			end
		end
	end
end

function worldlayers.is_action_allowed(pos, node, action)
	for _, layer in worldlayers.iter(pos) do
		local restriction_table = layer.restrictions
		if restriction_table then
			local restriction = restriction_table[action]
			if type(restriction) == "table" then
				if restriction[node] ~= nil then
					return restriction[node]
				elseif restriction.general ~= nil then
					return restriction.general
				end
			elseif type(restriction) == "boolean" then
				return restriction
			end
		end
	end
	return true
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local old_node = minetest.get_node(pos).name
	local node, action
	if old_node ~= "air" then
		node = old_node
		action = "dig"
	else
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		local new_node = player:get_wielded_item():get_name()
		if node ~= "" then
			node = new_node
			action = "place"
		end
	end
	local is_protected = not worldlayers.is_action_allowed(pos, node, action)
	return is_protected or old_is_protected(pos, name)
end
