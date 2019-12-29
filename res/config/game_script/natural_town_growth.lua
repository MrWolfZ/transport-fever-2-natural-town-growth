local col = require 'natural_town_growth/collections'
local debug = require 'natural_town_growth/debug'
local log = require 'natural_town_growth/logging'
local serialization = require 'natural_town_growth/serialization'
local util = require 'natural_town_growth/util'

local state = {
  version = 0,
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
  local cargoSupply = game.interface.getTownCargoSupplyAndLimit(town.id)
  local cargoSupplyTypeIds = col.keys(cargoSupply)

  log.trace('town ' .. town.name .. ' has cargo type IDs: ' .. serialization.stringify(cargoSupplyTypeIds))

  local sumOfCargoSupplies = 0
  col.forEach(
    cargoSupplyTypeIds,
    function (cargoTypeId)
      local currentSupply = cargoSupply[cargoTypeId][1]
      sumOfCargoSupplies = sumOfCargoSupplies + currentSupply
    end
  )

  log.trace('town ' .. town.name .. ' has total cargo supply of ' .. sumOfCargoSupplies)

  local config = util.getSettings().growth.residential

  local scaledBaseCapacity = getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].residential
  local capacityFromSupply = sumOfCargoSupplies * config.cargoSupplyFactor
  local capacityFromPublicTransportReachability = util.getTownPublicTransportReachability(town) * config.publicTransportReachabilityFactor
  local capacityFromPrivateTransportReachability = util.getTownPrivateTransportReachability(town) * config.privateTransportReachabilityFactor
  local capacityFromReachability = capacityFromPublicTransportReachability + capacityFromPrivateTransportReachability

  local residentialCapacity = scaledBaseCapacity + capacityFromSupply + capacityFromReachability

  log.debug('town ' .. town.name .. ' has residential capacity of ' .. residentialCapacity .. ' based on these values:\nscaledBaseCapacity: ' .. scaledBaseCapacity .. '\ncapacityFromSupply: ' .. capacityFromSupply .. '\ncapacityFromReachability: ' .. capacityFromReachability)

  return residentialCapacity
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

  local sumOfCommercialCargoSupplies = 0
  col.forEach(
    commercialCargoSupplyTypeIds,
    function (cargoTypeId)
      local currentSupply = cargoSupply[cargoTypeId][1]
      sumOfCommercialCargoSupplies = sumOfCommercialCargoSupplies + currentSupply
    end
  )

  log.trace('town ' .. town.name .. ' has commercial cargo supply of ' .. sumOfCommercialCargoSupplies)

  local config = util.getSettings().growth.commercial

  local scaledBaseCapacity = getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].commercial
  local capacityFromSupply = sumOfCommercialCargoSupplies * config.cargoSupplyFactor
  local capacityFromPublicTransportReachability = util.getTownPublicTransportReachability(town) * config.publicTransportReachabilityFactor
  local capacityFromPrivateTransportReachability = util.getTownPrivateTransportReachability(town) * config.privateTransportReachabilityFactor
  local capacityFromReachability = capacityFromPublicTransportReachability + capacityFromPrivateTransportReachability

  local commercialCapacity = scaledBaseCapacity + capacityFromSupply + capacityFromReachability

  log.debug('town ' .. town.name .. ' has commercial capacity of ' .. commercialCapacity .. ' based on these values:\nscaledBaseCapacity: ' .. scaledBaseCapacity .. '\ncapacityFromSupply: ' .. capacityFromSupply .. '\ncapacityFromReachability: ' .. capacityFromReachability)

  return commercialCapacity
end

local function calculateIndustrialCapacity(town)
  local cargoSupply = game.interface.getTownCargoSupplyAndLimit(town.id)
  local cargoSupplyTypeIds = col.keys(cargoSupply)
  local industrialCargoTypeIds = util.getIndustrialCargoTypeIds()
  local industrialCargoSupplyTypeIds = col.filter(
    cargoSupplyTypeIds,
    function (cargoTypeId)
      return col.contains(industrialCargoTypeIds, cargoTypeId)
    end
  )

  log.trace('town ' .. town.name .. ' has industrial cargo type IDs: ' .. serialization.stringify(industrialCargoSupplyTypeIds))

  local sumOfIndustrialCargoSupplies = 0
  col.forEach(
    industrialCargoSupplyTypeIds,
    function (cargoTypeId)
      local currentSupply = cargoSupply[cargoTypeId][1]
      sumOfIndustrialCargoSupplies = sumOfIndustrialCargoSupplies + currentSupply
    end
  )


  log.trace('town ' .. town.name .. ' has industrial cargo supply of ' .. sumOfIndustrialCargoSupplies)

  local config = util.getSettings().growth.commercial

  local scaledBaseCapacity = getBaseCapacity() * state.baseCapacity.scalingFactors[town.id].industrial
  local capacityFromSupply = sumOfIndustrialCargoSupplies * config.cargoSupplyFactor
  local capacityFromPublicTransportReachability = util.getTownPublicTransportReachability(town) * config.publicTransportReachabilityFactor
  local capacityFromPrivateTransportReachability = util.getTownPrivateTransportReachability(town) * config.privateTransportReachabilityFactor
  local capacityFromReachability = capacityFromPublicTransportReachability + capacityFromPrivateTransportReachability

  local industrialCapacity = scaledBaseCapacity + capacityFromSupply + capacityFromReachability

  log.debug('town ' .. town.name .. ' has industrial capacity of ' .. industrialCapacity .. ' based on these values:\nscaledBaseCapacity: ' .. scaledBaseCapacity .. '\ncapacityFromSupply: ' .. capacityFromSupply .. '\ncapacityFromReachability: ' .. capacityFromReachability)

  return industrialCapacity
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

local function init()
  log.info('initializing mod...')

  -- debug.printTowns()
  -- debug.printCargoTypes()

  setBaseCapacityScalingFactors()
  setTownCapacities()
end

local function update()
  -- prevent updating the capacities too often unnecessarily
  if state.counter >= 100 then
    setTownCapacities()

    -- debug.printTowns()
    -- debug.printTownCapacities()

    state.counter = 0
  end

  state.counter = state.counter + 1
end

local function save()
  return state
end

local function load(allState)
  -- handle case where mod is added to existing save game
  if not allState then
    init()
    allState = state
  end

  state = allState
end

function data()
  return {
    init = init,
    update = update,
		save = save,
    load = load,
  }
end
