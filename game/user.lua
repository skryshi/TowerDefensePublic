-- Copyright 2013 Arman Darini
local class = {}
class.new = function(o)
	local User = {}

	----------------------------------------------------------
	function User:init(o)
		local id = system.getInfo("deviceID")
		self._persistent = {
			username = id,
			password = Utils.generateRandomString(12, 15),
			version = 3,
			soundVolume = 1,
			musicVolume = 1,
			credits = 100,
		}
		--	put all persistent data into main namespace
		Utils.mergeTable(self, self._persistent)

		return self
	end

	----------------------------------------------------------
	function User:get()
--		self:getFromFile()
		self:getFromMock()
	end

	----------------------------------------------------------
	function User:getFromFile()
		data = Utils.loadTable("user")
		if data and data.version and data.version >= self._persistent.version then
			p("Loaded valid user data")
			Utils.mergeTable(self._persistent, data)
		else
			self:save()
		end
		--	put all persistent data into main namespace
		Utils.mergeTable(self, self._persistent)
	end

	----------------------------------------------------------
	function User:getFromMock()
		self._persistent = {
			objectId = "hodsihsd",
			createdAt = "01012013 12:30:30",
			username = "Dragon",
			password = "df23fesad",
			version = 3,
			soundVolume = 1,
			musicVolume = 1,
			credits = 100,
		}
		--	put all persistent data into main namespace
		Utils.mergeTable(self, self._persistent)
	end

	----------------------------------------------------------
	function User:save()
		-- copy all persistent data from main namespace
		for k, _ in pairs(self._persistent) do
			if self[k] then
				self._persistent[k] = self[k]
			end
		end
		Utils.saveTable(self._persistent, "user")
	end

	----------------------------------------------------------
	function User:print()
		for k, _ in pairs(self._persistent) do
			p(self[k])
		end
	end

	----------------------------------------------------------
	function User:removeSelf()
	end

	----------------------------------------------------------
	return User:init(o)
end

return class