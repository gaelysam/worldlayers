local modpath = minetest.get_modpath("worldlayers")
dofile(modpath .. "/api.lua")

worldlayers.register_layer({
	ymin = -31000,
	ymax = -100,
	restrictions = {
		place = {
			["default:chest"] = false,
			["default:chest_locked"] = false,
		},
	},
})
