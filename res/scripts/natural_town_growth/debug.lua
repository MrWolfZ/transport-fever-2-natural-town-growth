local log = require 'natural_town_growth/logging'
local serialization = require 'natural_town_growth/serialization'
local util = require 'natural_town_growth/util'

local functions = {}

function functions.printTowns()
  util.forEachTown(
    function (town)
      log.debug('town "' .. town.name .. '":\n' .. serialization.stringify(town))
      log.debug('getTownCargoSupplyAndLimit:\n' .. serialization.stringify(game.interface.getTownCargoSupplyAndLimit(town.id)))
      log.debug('getTownReachability:\n' .. serialization.stringify(game.interface.getTownReachability(town.id)))
      log.debug('getTownCapacities:\n' .. serialization.stringify(game.interface.getTownCapacities(town.id)))
      log.debug('getTownTransportSamples:\n' .. serialization.stringify(game.interface.getTownTransportSamples(town.id)))
      log.debug('getTownTrafficRating:\n' .. serialization.stringify(game.interface.getTownTrafficRating(town.id)))
    end
  )
end

function functions.printTownCapacities()
  util.forEachTown(
    function (town)
      local capacities = game.interface.getTownCapacities(town.id)
      local residentialCapacity = capacities[1]
      local commercialCapacity = capacities[2]
      local industrialCapacity = capacities[3]
      log.trace('town "' .. town.name .. '" capacities: residential: ' .. residentialCapacity .. ', commercial: ' .. commercialCapacity .. ', industrial: ' .. industrialCapacity)
    end
  )
end

function functions.printCargoTypes()
  log.debug('cargo types:')

  col.forEach(
    util.getCargoTypes(),
    function (cargoType)
      log.debug('\n' .. serialization.stringify(cargoType))
    end
  )
end

return functions

-- game.interface functions:
-- addPlayer
-- book
-- buildConstruction
-- bulldoze
-- clearJournal
-- findPath
-- getBuildingType
-- getBuildingTypes
-- getCargoType
-- getCargoTypes
-- getCompanyScore
-- getConstructionEntity
-- getDateFromNowPlusOffsetDays
-- getDepots
-- getDestinationDataPerson
-- getEntities
-- getEntity
-- getGameDifficulty
-- getGameSpeed
-- getGameTime
-- getHeight
-- getIndustryProduction
-- getIndustryProductionLimit
-- getIndustryShipping
-- getIndustryTransportRating
-- getLines
-- getLog
-- getMillisPerDay
-- getName
-- getPlayer
-- getPlayerJournal
-- getStationTransportSamples
-- getStations
-- getTownCapacities
-- getTownCargoSupplyAndLimit
-- getTownEmission
-- getTownReachability
-- getTownTrafficRating
-- getTownTransportSamples
-- getTowns
-- getVehicles
-- getWorld
-- replaceVehicle
-- setBuildInPauseModeAllowed
-- setBulldozeable
-- setDate
-- setGameSpeed
-- setMarker
-- setMaximumLoan
-- setMillisPerDay
-- setMinimumLoan
-- setMissionState
-- setName
-- setPlayer
-- setTownCapacities
-- setTownDevelopmentActive
-- setZone
-- spawnAnimal
-- startEvent
-- upgradeConstruction