function data()
	return {
		info = {
			minorVersion = 0,
			severityAdd = "NONE",
			severityRemove = "NONE",
			name = _("Name"),
			description = _("Description"),
			tags = { "Script Mod" },
			authors = {
				{
					name = "MrWolfZ",
					role = 'CREATOR',
				},
			},
		},
		-- TODO: figure out why options do not work
		categories = {
			{ key = "foo", name = _("Foo") },
			{ key = "climate", name = _("Bar") },
		},
		options = {
			foo = { { "test1", _("Test entry 1") }, { "test2", _("Test entry 2") } },
		},
		runFn = function (settings)
			-- not sure if this works, but it seems useful to decrease
			-- the develop interval due to the increase in town sizes
			game.config.townDevelopInterval = 20

			-- create a separate config state container to ensure there are no conflicts
			game.config.mrwolfz = game.config.mrwolfz or {}
			game.config.mrwolfz.naturalTownGrowth = {
				baseCapacity = {
					initial = 100,
					growthPerYear = 0.5,
					scalingFactors = {
						residential = {
							min = 0.8,
							max = 1.2,
						},
						commercial = {
							min = 0.4,
							max = 0.6,
						},
						industrial = {
							min = 0.4,
							max = 0.6,
						},
					},
				},
				growth = {
					residential = {
						supplyFactor = 0.2,
						publicTransportReachabilityFactor = 0.015,
						privateTransportReachabilityFactor = 0.015,
					},
					commercial = {
						supplyFactor = 1.5,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
					industrial = {
						supplyFactor = 1.5,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
				},
			}
		end,
	}
end
