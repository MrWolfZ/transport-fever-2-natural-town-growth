local col = require 'natural_town_growth/collections'
local debug = require 'natural_town_growth/debug'
local log = require 'natural_town_growth/logging'
local serialization = require 'natural_town_growth/serialization'
local util = require 'natural_town_growth/util'

local state = {
  minorVersion = 0,
  lastUpdatedAtEpoch = 0,
  baseCapacity = {
    scalingFactors = {},
  },
  capacitiesByTownId = {},
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
  log.debug('setting town capacities...')

  util.forEachTown(
    function(town)
      local currentEpoch = util.getEpoch()

      -- ensure capacities for city are initialized
      state.capacitiesByTownId[town.id] = state.capacitiesByTownId[town.id] or {
        residential = {
          value = 0,
          setAtEpoch = currentEpoch,
        },
        commercial = {
          value = 0,
          setAtEpoch = currentEpoch,
        },
        industrial = {
          value = 0,
          setAtEpoch = currentEpoch,
        },
      }

      local capacities = state.capacitiesByTownId[town.id]
      
      local residential = calculateResidentialCapacity(town)
      local commercial = calculateCommercialCapacity(town)
      local industrial = calculateIndustrialCapacity(town)

      -- to prevent size decreases due to fluctuating supply we only accept size
      -- decreases if some time has passed since the last update
      local decreaseThresholdInSeconds = util.getSettings().timeThresholdForSizeDecreaseInSeconds

      local secondsSinceLastResidentialUpdate = currentEpoch - capacities.residential.setAtEpoch
      local prevResidential = capacities.residential.value
      local residentialShouldUpdate = residential > prevResidential or (residential < prevResidential and secondsSinceLastResidentialUpdate > decreaseThresholdInSeconds)
      if residentialShouldUpdate then
        capacities.residential.value = residential
        capacities.residential.setAtEpoch = currentEpoch
      else
        log.debug('skipping residential size decrease for town ' .. town.name .. ' since only ' .. secondsSinceLastResidentialUpdate .. ' seconds have passed since last update...')
      end

      local secondsSinceLastCommercialUpdate = currentEpoch - capacities.commercial.setAtEpoch
      local prevCommercial = capacities.commercial.value
      local commercialShouldUpdate = commercial > prevCommercial or (commercial < prevCommercial and secondsSinceLastCommercialUpdate > decreaseThresholdInSeconds)
      if commercialShouldUpdate then
        capacities.commercial.value = commercial
        capacities.commercial.setAtEpoch = currentEpoch
      else
        log.debug('skipping commercial size decrease for town ' .. town.name .. ' since only ' .. secondsSinceLastCommercialUpdate .. ' seconds have passed since last update...')
      end

      local secondsSinceLastIndustrialUpdate = currentEpoch - capacities.industrial.setAtEpoch
      local prevIndustrial = capacities.industrial.value
      local industrialShouldUpdate = industrial > prevIndustrial or (industrial < prevIndustrial and secondsSinceLastIndustrialUpdate > decreaseThresholdInSeconds)
      if industrialShouldUpdate then
        capacities.industrial.value = industrial
        capacities.industrial.setAtEpoch = currentEpoch
      else
        log.debug('skipping industrial size decrease for town ' .. town.name .. ' since only ' .. secondsSinceLastIndustrialUpdate .. ' seconds have passed since last update...')
      end

      game.interface.setTownCapacities(
        town.id,
        capacities.residential.value,
        capacities.commercial.value,
        capacities.industrial.value
      )
    end
  )
end

local function init()
  log.info('initializing mod...')

  setBaseCapacityScalingFactors()
  setTownCapacities()
end

local function update()
  -- prevent updating the capacities too often unnecessarily
  local currentEpoch = util.getEpoch()
  local secondsSinceLastUpdate = currentEpoch - state.lastUpdatedAtEpoch

  if secondsSinceLastUpdate < 10 then
    log.trace('skipping update since only ' .. secondsSinceLastUpdate .. ' seconds have passed since last update...')
    return
  end

  setTownCapacities()
end

local function save()
  state.minorVersion = game.config.mrwolfz.naturalTownGrowth.minorVersion

  return state
end

local stateMigrations = {
  -- [0] = function (state)
  --   return state
  -- end,
}

local function load(loadedState)
  -- handle case where mod is added to existing save game
  if not loadedState then
    init()
    loadedState = state
  end

  -- run state migrations
  local currentMinorVersion = game.config.mrwolfz.naturalTownGrowth.minorVersion
  if currentMinorVersion > loadedState.minorVersion then
    log.info('running state migrations for loaded state of minor version ' .. loadedState.minorVersion .. ' to current minor version ' .. currentMinorVersion ..'...')
    for i = loadedState.minorVersion, currentMinorVersion do
      if stateMigrations[i] then
        log.info('running state migrations for version ' .. i .. '...')
        loadedState = stateMigrations[i](loadedState)
      end
    end
  end

  loadedState.minorVersion = currentMinorVersion

  state = loadedState
end

function data()
  return {
    init = init,
    update = update,
		save = save,
    load = load,
  }
end
