local col = require 'natural_town_growth/collections'

local functions = {}

function functions.getSettings()
  return game.config.mrwolfz.naturalTownGrowth
end

function functions.forEachTown(fn)
  local townIds = game.interface.getTowns()
  local towns = col.map(
    townIds,
    function (townId)
      return game.interface.getEntity(townId)
    end
  )

  col.forEach(towns, fn)
end

function functions.getCargoTypes()
  local cargoTypeIds = game.interface.getCargoTypes()
  return col.map(
    cargoTypeIds,
    function (cargoTypeId)
      return game.interface.getCargoType(cargoTypeId)
    end
  )
end

function functions.getCommercialCargoTypes()
  return col.filter(
    functions.getCargoTypes(),
    function (cargoType)
      return col.contains(cargoType.townInput, 'COMMERCIAL')
    end
  )
end

function functions.getCommercialCargoTypeIds()
  return col.map(
    functions.getCommercialCargoTypes(),
    function (cargoType)
      return cargoType.id
    end
  )
end

function functions.getIndustrialCargoTypes()
  return col.filter(
    functions.getCargoTypes(),
    function (cargoType)
      return col.contains(cargoType.townInput, 'INDUSTRIAL')
    end
  )
end

function functions.getIndustrialCargoTypeIds()
  return col.map(
    functions.getIndustrialCargoTypes(),
    function (cargoType)
      return cargoType.id
    end
  )
end

function functions.getTownPublicTransportReachability(town)
  game.interface.getTownReachability(town.id)[2]
end

function functions.getTownPrivateTransportReachability(town)
  game.interface.getTownReachability(town.id)[1]
end

return functions
