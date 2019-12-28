local functions = {}

function functions.map(arr, fn)
  local result = {}
  for i = 1, #arr do
    result[i] = fn(arr[i])
  end

  return result
end

function functions.filter(arr, fn)
  local result = {}
  local j = 1
  for i = 1, #arr do
    if fn(arr[i]) then
      result[j] = arr[i]
      j = j + 1
    end
  end

  return result
end

function functions.forEach(arr, fn)
  for i = 1, #arr do
    fn(arr[i])
  end
end

function functions.contains(arr, item)
  local isContained = false

  functions.forEach(
    arr,
    function (i)
      isContained = isContained or i == item
    end
  )

  return isContained
end

function functions.keys(tab)
  local keys = {}
  local i = 0

  for k, v in pairs(tab) do
    i = i + 1
    keys[i] = k
  end

  return keys
end

return functions
