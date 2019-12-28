local functions = {}

-- copied from the game's serialization code in scripts/serialize.lua
local function serializeRec(o, prefix, writeFn)
	local function writeKey(k)
		if type(k) == "string" and string.find(k, "^[_%a][_%w]*$") then
			writeFn(k, " = ")
		else
			writeFn("[")
			serializeRec(k, "", writeFn)
			writeFn("] = ")
		end
	end

	if type(o) == "nil" then
		writeFn("nil")
	elseif type(o) == "boolean" then
		writeFn(tostring(o))
	elseif type(o) == "number" then
		writeFn(o)
	elseif type(o) == "string" then
		writeFn(string.format("%q", o))
	elseif type(o) == "table" then
		local metatag = o["__metatag__"]
		if metatag then
			if metatag == 0 then
				writeFn("_(")
				serializeRec(o.val, prefix, writeFn)
				writeFn(")")
			else
				error("invalid metatag: " .. metatag)
			end
			return
		end
		
		local oneLine = true
		local listKeys = {}
		local tableKeys = {}
		for k,v in ipairs(o) do
			listKeys[k] = true
		end
		for k,v in pairs(o) do
			if type(v) == "table" then oneLine = false end
			if not listKeys[k] then
				table.insert(tableKeys, k)
				oneLine = false
			end
		end
		table.sort(tableKeys)
		
		if oneLine then
			writeFn("{ ")
			for k,v in ipairs(o) do
				serializeRec(v, "", writeFn)
				writeFn(", ")
			end
			for i,k in ipairs(tableKeys) do
				local v = o[k]
				writeKey(k)
				serializeRec(v, "", writeFn)
				writeFn(", ")	
			end
			writeFn("}")
		else
			local prefix2 = prefix .. "\t"
			writeFn("{\n")
			for k,v in ipairs(o) do
				writeFn(prefix2)
				serializeRec(v, prefix2, writeFn)
				writeFn(",\n")
			end
			for i,k in ipairs(tableKeys) do
				local v = o[k]
				writeFn(prefix2)
				writeKey(k)
				serializeRec(v, prefix2, writeFn)
				writeFn(",\n")	
			end
			writeFn(prefix, "}")
		end
	elseif type(o) == "userdata" then
		local mt = getmetatable(o)
		local members = mt.__members
		if mt and mt.pairs then
			local prefix2 = prefix .. "\t"
			writeFn("{\n")
			for k,v in pairs(o) do
				writeFn(prefix2)
				writeKey(k)
				serializeRec(v, prefix2, writeFn)
				writeFn(",\n")
			end
			writeFn(prefix, "}")
		elseif mt and members then
			local prefix2 = prefix .. "\t"
			writeFn("{\n")
			for i = 1, #members do
				local k = members[i]
				local v = o[k]
				writeFn(prefix2)
				writeKey(k)
				serializeRec(v, prefix2, writeFn)
				writeFn(",\n")	
			end
			writeFn(prefix, "}")
		else
			writeFn(tostring(o))
		end
	end
end

function functions.stringify(o)
	local s = ''

	local function write(...)
		local arg = {...}
		for i, v in ipairs(arg) do
			s = s .. v
		end
	end

	serializeRec(o, '', write)

	return s
end

return functions
