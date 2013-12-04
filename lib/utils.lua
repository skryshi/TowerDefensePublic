-- Copyright 2013 Arman Darini

utils = {}

----------------------------------------------------------
utils.p = function(t)
	if nil == t then
		print("nil")
		return
	elseif "table" ~= type(t) then
		print(t)
		return
	end

	local empty = true
	for k, v in pairs(t) do
		empty = false
		if "table" == type(v) then
			local s = ""
			for k2, v2 in pairs(v) do
				s = s .. ("table" ~= type(v2) and tostring(v2) or "{..}") .. " "
			end
			print(k, "=", s)
		else
			print(k, "=", v)
		end
	end
	if empty then
		print("{}")
	end
end

----------------------------------------------------------
-- putting print into global namespace as p
p = utils.p

----------------------------------------------------------
utils.printDisplayObject = function(obj)
	print("x="..obj.x, "y="..obj.y, "xOr="..obj.xOrigin, "yOr="..obj.yOrigin, "xRef="..obj.xReference, "yRef="..obj.yReference, "w="..obj.width, "h="..obj.height)
end

----------------------------------------------------------
utils.printMemoryUsed = function()
   collectgarbage( "collect" )
   local memUsage = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   print( memUsage, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end

----------------------------------------------------------
utils.saveTable = function(t, filename, dir)
	local dir = dir or system.DocumentsDirectory
	local path = system.pathForFile(filename, dir)
	local file = io.open(path, "w")
	if file then
		local contents = Json.encode(t)
		file:write(contents)
		io.close( file )
		return true
	else
		return false
	end
end

----------------------------------------------------------
utils.loadTable = function(filename, dir)
	local dir = dir or system.DocumentsDirectory
	local path = system.pathForFile(filename, dir)
	local contents = ""
	local t = {}
	local file = io.open(path, "r")
	if file then
		local contents = file:read("*a")
		t = Json.decode(contents)
		io.close(file)
		return t 
	end
	return nil
end

----------------------------------------------------------
utils.copyTable = function(t)
	return Json.decode(Json.encode(t))
--[[
  local t2 = {}
  for k, v in pairs(t) do
    t2[k] = v
  end
  return t2
]]
end

----------------------------------------------------------
utils.mergeTable = function(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            utils.mergeTable(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

----------------------------------------------------------
utils.getPhysicsData = function(shapesPath, sheetPath, scale)
	print("getPhysicsData")
	local scale = scale or 1
	local physicsData = (require(shapesPath)).physicsData(scale)
	local sheetInfo = require(sheetPath)
	local visualInfo

	for k, _ in pairs(physicsData.data) do
		visualInfo = sheetInfo:getSheet().frames[sheetInfo:getFrameIndex(k)]
		for i = 1, #physicsData.data[k] do
--				p(physicsData.data[k])
			for j = 1, #physicsData.data[k][i].shape do
				if 1 == j % 2 then	-- x coordinate
					physicsData.data[k][i].shape[j] = physicsData.data[k][i].shape[j] + sheetInfo:getSheet().sheetContentWidth / 2 - (visualInfo.x + visualInfo.width / 2)
				else	-- y coordinate
					physicsData.data[k][i].shape[j] = physicsData.data[k][i].shape[j] + sheetInfo:getSheet().sheetContentHeight / 2 - (visualInfo.y + visualInfo.height / 2)
				end
			end
		end
	end
	
	return physicsData
end

----------------------------------------------------------
utils.generateRandomString = function(s, l)
	--http://pastebin.com/DruT1MC6
	 -- args: smallest and largest possible password lengths, inclusive
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9", "@", "#", "$", "%", "&", "?"}

	math.randomseed(os.time())
	pass = {}
	size = math.random(s,l) -- random password length
	for z = 1, size do
		case = math.random(1,2) -- randomly choose case (caps or lower)
		a = math.random(1,#char) -- randomly choose a character from the "char" array
		if case == 1 then
			x=string.upper(char[a]) -- uppercase if case = 1
		elseif case == 2 then
			x=string.lower(char[a]) -- lowercase if case = 2
		end
	table.insert(pass, x) -- add new index into array.
	end
	return(table.concat(pass)) -- concatenate all indicies of the "pass" array, then print out concatenation.
end

----------------------------------------------------------
function lambda(...)
	local func = arg[1]
	local outerArgs = arg
	table.remove(outerArgs, 1)
	return function(...)
		func(unpack(outerArgs), unpack(arg))
	end
end

return utils