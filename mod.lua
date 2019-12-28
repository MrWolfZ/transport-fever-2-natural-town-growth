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
			game.config.mrwolfz = game.config.mrwolfz or {}
			game.config.mrwolfz.naturalTownGrowth = {
				baseCapacity = {
					initial = 100,
					growthPerYear = 1,
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
					},
					commercial = {
						supplyFactor = 2,
						publicTransportReachabilityFactor = 0.01,
						privateTransportReachabilityFactor = 0.01,
					},
					industrial = {
						supplyFactor = 2,
						publicTransportReachabilityFactor = 0.01,
						privateTransportReachabilityFactor = 0.01,
					},
				},
			}
		end,
	}
end
