local col = require 'natural_town_growth/collections'
local debug = require 'natural_town_growth/debug'
local log = require 'natural_town_growth/logging'
local serialization = require 'natural_town_growth/serialization'
local util = require 'natural_town_growth/util'

local state = {
  counter = 0,
  baseCapacity = {
    scalingFactors = {},
  },
}

local function getBaseCapacity()
	local year = game.interface.getGameTime().date.year
  local config = util.getSettings().baseCapacity
	return config.initial + (year - 1850) * config.growthPerYear
end

local function calculateResidentialCapacity(town)
  return getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].residential
end

local function calculateCommercialCapacity(town)
  local cargoSupply = game.interface.getTownCargoSupplyAndLimit(town.id)
  local cargoSupplyTypeIds = col.keys(cargoSupply)
  local commercialCargoTypeIds = util.getCommercialCargoTypeIds()
  local commercialCargoSupplyTypeIds = col.filter(
    cargoSupplyTypeIds,
    function (cargoTypeId)
      return col.contains(commercialCargoTypeIds, cargoTypeId)
    end
  )

  log.trace('town ' .. town.name .. ' has commercial cargo type IDs: ' .. serialization.stringify(commercialCargoSupplyTypeIds))

  local sumOfCommercialCargoSupplyRatios = 0
  col.forEach(
    commercialCargoSupplyTypeIds,
    function (cargoTypeId)
      local currentSupply = cargoSupply[cargoTypeId][1]
      local maxSupply = cargoSupply[cargoTypeId][2]

      sumOfCommercialCargoSupplyRatios = sumOfCommercialCargoSupplyRatios + (currentSupply / maxSupply)
    end
  )

  local averageCommercialCargoSupply = sumOfCommercialCargoSupplyRatios / #commercialCargoSupplyTypeIds

  log.trace('town ' .. town.name .. ' has average commercial cargo supply of ' .. averageCommercialCargoSupply)

  local config = util.getSettings().growth.commercial

  local scaledBaseCapacity = getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].commercial
  local capacityFromSupply = getBaseCapacity() * averageCommercialCargoSupply * config.supplyFactor
  local capacityFromPublicTransportReachability = util.getTownPublicTransportReachability() * config.publicTransportReachabilityFactor
  local capacityFromPrivateTransportReachability = util.getTownPrivateTransportReachability() * config.privateTransportReachabilityFactor
  local capacityFromReachability = capacityFromPublicTransportReachability + capacityFromPrivateTransportReachability

  local commercialCapacity = scaledBaseCapacity + capacityFromSupply + capacityFromReachability

  log.debug('town ' .. town.name .. ' has commercial capacity of ' .. commercialCapacity .. ' based on these values:\nscaledBaseCapacity: ' .. scaledBaseCapacity .. '\ncapacityFromSupply: ' .. capacityFromSupply .. '\ncapacityFromReachability: ' .. capacityFromReachability)

  return commercialCapacity
end

local function calculateIndustrialCapacity(town)
  return getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].industrial
end

local function setBaseCapacityScalingFactors()
  log.debug('setting town scaling factors...')

  local config = util.getSettings().baseCapacity.scalingFactors

  -- I observed math.random always returning the same numbers, therefore
  -- we forcefully reseed the random generator
  math.randomseed(os.time())

  util.forEachTown(
    function(town)
      local residential = math.random(config.residential.min * 100, config.residential.max * 100) / 100
      local commercial = math.random(config.commercial.min * 100, config.commercial.max * 100) / 100
      local industrial = math.random(config.industrial.min * 100, config.industrial.max * 100) / 100

      state.baseCapacity.scalingFactors[town.id] = {
        residential = residential,
        commercial = commercial,
        industrial = industrial,
      }
      
      log.debug('town ' .. town.name .. ' has scaling factors:\n' .. serialization.stringify(state.baseCapacity.scalingFactors[town.id]))
    end
  )
end

local function setTownCapacities()
  log.trace('setting town capacities...')

  util.forEachTown(
    function(town)
      game.interface.setTownCapacities(
        town.id,
        calculateResidentialCapacity(town),
        calculateCommercialCapacity(town),
        calculateIndustrialCapacity(town)
      )
    end
  )
end

function data()
  return {
    init = function()
      log.setLevel(log.levels.TRACE)

      -- debug.printTowns()
      -- debug.printCargoTypes()

      setBaseCapacityScalingFactors()
      setTownCapacities()
    end,
    update = function()
      -- prevent updating the capacities too often unnecessarily
      if state.counter >= 1000 then
        setTownCapacities()

        -- debug.printTowns()
        -- debug.printTownCapacities()
        
        state.counter = 0
      end

      state.counter = state.counter + 1
    end,
		save = function ()
			return state
		end,
		load = function (allState)
			state = allState or state
		end,
  }
end
