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
			--  1870 |    0 |    0 |     0 |  200 |  113 |   56 |   56 |  13 |  40 |  177 |   97 |   97
			--  1870 |   50 |   50 |   400 |  200 |  152 |  108 |  108 |  13 |  40 |  231 |  170 |  170
			--  1870 |  100 |    0 |   400 |  200 |  152 |  158 |   58 |  13 |  40 |  231 |  240 |  100
			--  1900 |    0 |    0 |     0 |  300 |  130 |   64 |   64 |  33 |  30 |  212 |  127 |  127
			--  1900 |  100 |  100 |  1000 |  300 |  211 |  169 |  169 |  33 |  80 |  439 |  364 |  364
			--  1900 |  200 |    0 |  1000 |  300 |  211 |  269 |   69 |  33 |  80 |  439 |  544 |  184
			--  1950 |    0 |    0 |     0 |  400 |  156 |   77 |   77 |  67 |  40 |  312 |  201 |  201
			--  1950 |  200 |  200 |  2400 |  800 |  330 |  291 |  291 |  67 | 140 |  952 |  858 |  858
			--  1950 |  400 |    0 |  2400 |  800 |  330 |  491 |   91 |  67 | 140 |  952 | 1338 |  378
			--  2000 |    0 |    0 |     0 |  600 |  184 |   91 |   91 | 100 |  40 |  398 |  367 |  367
			--  2000 |  400 |  400 |  5000 | 2000 |  544 |  523 |  523 | 100 | 210 | 1996 | 1930 | 1930
			--  2000 |  800 |    0 |  5000 | 2000 |  544 |  923 |  123 | 100 | 210 | 1996 | 2790 |  690
			--  2050 |    0 |    0 |     0 |  800 |  212 |  104 |  104 | 133 |  40 |  483 |  332 |  332
			--  2050 |  300 |  300 |  8000 | 4000 |  578 |  460 |  460 | 133 | 300 | 2845 | 2373 | 2373
			--  2050 |  600 |  600 | 10000 | 5000 |  821 |  775 |  775 | 133 | 300 | 3695 | 3633 | 3633
			--  2050 | 1200 |    0 | 10000 | 5000 |  821 |  800 |  175 | 133 | 300 | 3695 | 3733 | 1233
			
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
						cargoSupplyFactor = 0.33,
						publicTransportReachabilityFactor = 0.015,
						privateTransportReachabilityFactor = 0.015,
					},
					commercial = {
						cargoSupplyFactor = 1,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
					industrial = {
						cargoSupplyFactor = 1,
						publicTransportReachabilityFactor = 0.005,
						privateTransportReachabilityFactor = 0.005,
					},
				},
			}
		end,
	}
end
