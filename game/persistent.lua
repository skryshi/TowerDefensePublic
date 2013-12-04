-- Copyright 2013 Arman Darini

local class = {}
class.new = function(o)
	local Persistent = {}

	----------------------------------------------------------
	function Persistent:init(o)
		self.persistent = self
		self._persistent = {}

		return self
	end

	----------------------------------------------------------
	function Persistent:getFromLocal(filename, path)
		path = path or system.ResourceDirectory
		local data = Utils.loadTable(filename, path)
		if data then
			Utils.mergeTable(self._persistent, data)
			--	put all persistent data into main namespace
			Utils.mergeTable(self, self._persistent)
			local response = { name = "get", class = self._persistent.class, result = "200" }
		else
			local response = { name = "get", class = self._persistent.class, result = "404" }
		end
		Runtime:dispatchEvent(response)
		p(response)
	end

	----------------------------------------------------------
	function Persistent:destroy()
	end

	----------------------------------------------------------
	return Persistent:init(o)
end

return class