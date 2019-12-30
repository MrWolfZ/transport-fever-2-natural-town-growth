function data()
	local minorVersion = 0

	return {
		info = {
			minorVersion = minorVersion,
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

			-- the parameters below control the size of towns; the final size of a town is
			-- determined by multiple factors:
			-- 1) the base initial size (seems to be capped at 800)
			-- 2) a random increase for the initial size over time
			-- 3) the percentage modifier based on reachability, supply, and environmental
			--    factors
			--
			-- the "initial size" shown in the town details is in fact the result of 1) and
			-- 2); the raw numbers of 1) can only be seen in sandbox mode in the details of
			-- the town
			--
			-- mods can only affect 1), which is what this mod does; the parameters below are
			-- chosen to make towns larger on average while keeping to the rough outlines of
			-- what the game thinks town sizes should be; note that town sizes seem to plateau
			-- at some point regardless of the target size
			--
			-- here are some examples of typical town sizes at certain dates, reachability
			-- rating and supply rating based on the parameters below:
			--
			--       |    supply   |     reach    | avg base init size | rnd |  %  |   avg final size
			--  year | COMM | INDU |  pub  | priv | RESI | COMM | INDU | inc | mod | RESI | COMM | INDU
			-- ------|------|------|-------|------|------|------|------|-----|-----|------|------|------
			--  1850 |    0 |    0 |     0 |  100 |  102 |   51 |   51 |   0 |  10 |  112 |   56 |   56
			--  1870 |    0 |    0 |     0 |  200 |  113 |   56 |   56 |   8 |  40 |  169 |   89 |   89
			--  1870 |   50 |   50 |   400 |  200 |  134 |   83 |   83 |   9 |  40 |  200 |  129 |  129
			--  1870 |  100 |    0 |   400 |  200 |  134 |  158 |   58 |   9 |  40 |  200 |  164 |   94
			--  1900 |    0 |    0 |     0 |  300 |  130 |   64 |   64 |  22 |  30 |  196 |  111 |  111
			--  1900 |  100 |  100 |  1000 |  300 |  175 |  119 |  119 |  29 |  80 |  366 |  267 |  267
			--  1900 |  200 |    0 |  1000 |  300 |  175 |  169 |   69 |  29 |  80 |  366 |  357 |  177
			--  1950 |    0 |    0 |     0 |  400 |  156 |   77 |   77 |  52 |  40 |  291 |  181 |  181
			--  1950 |  200 |  200 |  2400 |  800 |  228 |  191 |  191 |  86 | 140 |  826 |  665 |  665
			--  1950 |  400 |    0 |  2400 |  800 |  228 |  291 |   91 |  86 | 140 |  826 |  905 |  425
			--  2000 |    0 |    0 |     0 |  600 |  184 |   91 |   91 |  92 |  40 |  386 |  255 |  255
			--  2000 |  400 |  400 |  5000 | 2000 |  400 |  323 |  323 | 200 | 210 | 1860 | 1620 | 1620
			--  2000 |  800 |    0 |  5000 | 2000 |  400 |  523 |  123 | 200 | 210 | 1860 | 2240 | 1000
			--  2050 |    0 |    0 |     0 |  800 |  212 |  104 |  104 | 141 |  40 |  495 |  343 |  343
			--  2050 |  300 |  300 |  8000 | 4000 |  470 |  310 |  310 | 313 | 300 | 3133 | 2493 | 2493
			--  2050 |  600 |  600 | 10000 | 5000 |  605 |  475 |  475 | 403 | 300 | 4033 | 3513 | 3513
			--  2050 | 1200 |    0 | 10000 | 5000 |  605 |  775 |  175 | 403 | 300 | 4033 | 4713 | 2313
			
			game.config.mrwolfz.naturalTownGrowth = {
				minorVersion = minorVersion,
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
						cargoSupplyFactor = 0.15,
						publicTransportReachabilityFactor = 0.015,
						privateTransportReachabilityFactor = 0.015,
					},
					commercial = {
						cargoSupplyFactor = 0.5,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
					industrial = {
						cargoSupplyFactor = 0.5,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
				},
				timeThresholdForSizeDecreaseInSeconds = 180,
			}
		end,
	}
end
