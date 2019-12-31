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
    -- categories = {
    --   { key = "foo", name = _("Foo") },
    --   { key = "climate", name = _("Bar") },
    -- },
    -- options = {
    --   foo = { { "test1", _("Test entry 1") }, { "test2", _("Test entry 2") } },
    -- },
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
      -- rating and supply rating based on the parameters below (see also growth.xlsx):
      --
      --       |    supply   |     reach    | avg base init size | rnd |  %  |   avg final size
      --  year | COMM | INDU |  pub  | priv | RESI | COMM | INDU | inc | mod | RESI | COMM | INDU
      -- ------|------|------|-------|------|------|------|------|-----|-----|------|------|------
      --  1850 |    0 |    0 |     0 |  100 |  112 |   81 |   81 |   0 |  10 |  123 |   89 |   89
      --  1870 |    0 |    0 |     0 |  200 |  120 |   86 |   86 |   8 |  40 |  154 |  113 |  113
      --  1870 |   50 |   50 |   400 |  200 |  141 |  113 |  113 |   9 |  40 |  271 |  221 |  221
      --  1870 |  100 |    0 |   400 |  200 |  141 |  138 |   88 |   9 |  40 |  271 |  266 |  176
      --  1900 |    0 |    0 |     0 |  300 |  133 |   95 |   95 |  22 |  30 |  201 |  152 |  152
      --  1900 |  100 |  100 |  1000 |  300 |  178 |  150 |  150 |  30 |  80 |  456 |  395 |  395
      --  1900 |  200 |    0 |  1000 |  300 |  178 |  200 |  100 |  30 |  80 |  456 |  505 |  285
      --  1950 |    0 |    0 |     0 |  400 |  153 |  109 |  109 |  51 |  40 |  285 |  223 |  223
      --  1950 |  200 |  200 |  2400 |  800 |  255 |  223 |  223 |  85 | 140 |  951 |  861 |  861
      --  1950 |  400 |    0 |  2400 |  800 |  255 |  323 |  123 |  85 | 140 |  951 | 1141 |  581
      --  2000 |    0 |    0 |     0 |  600 |  174 |  123 |  123 |  87 |  40 |  365 |  294 |  294
      --  2000 |  400 |  400 |  5000 | 2000 |  390 |  355 |  355 | 195 | 210 | 1989 | 1870 | 1870
      --  2000 |  800 |    0 |  5000 | 2000 |  390 |  555 |  155 | 195 | 210 | 1989 | 2550 | 1190
      --  2050 |    0 |    0 |     0 |  800 |  195 |  137 |  137 | 130 |  40 |  456 |  375 |  375
      --  2050 |  300 |  300 |  8000 | 4000 |  453 |  343 |  343 | 302 | 300 | 3173 | 2711 | 2711
      --  2050 |  600 |  600 | 10000 | 5000 |  588 |  508 |  508 | 392 | 300 | 3922 | 3602 | 3602
      --  2050 | 1200 |    0 | 10000 | 5000 |  588 |  787 |  208 | 392 | 300 | 3922 | 4719 | 2402
      
      game.config.mrwolfz.naturalTownGrowth = {
        minorVersion = minorVersion,
        baseCapacity = {
          initial = 100,
          growthPerYear = 0.33333333333,
          scalingFactors = {
            residential = {
              min = 0.8,
              max = 1.4,
            },
            commercial = {
              min = 0.6,
              max = 1.0,
            },
            industrial = {
              min = 0.6,
              max = 1.0,
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
