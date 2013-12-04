-- Copyright 2013 Arman Darini

local class = {}
class.new = function(o)
	local Viewable = {}

	----------------------------------------------------------
	function Viewable:init(o)
		self.viewable = self
		self.view = display.newGroup()
		self.view.owner = self
		self.timers = {}
		self.transitions = {}
		self:setSheet((o and o.pathToImage) or "assets/images/sheet.png")

		return self
	end

	----------------------------------------------------------
	function Viewable:setSheet(pathToImage)
		pathToInfo, _ = string.gsub(pathToImage, "/", ".")
		pathToInfo = string.sub(pathToInfo, 1, #pathToInfo - 4)
		self.sheetInfo = require(pathToInfo)
		self.sheet = graphics.newImageSheet(pathToImage, self.sheetInfo:getSheet())		
	end

	----------------------------------------------------------
	function Viewable:destroy()
		for k, _ in pairs(self.timers) do
			timer.cancel(self.timers[k])
			self.timers[k] = nil
		end	
		for k, _ in pairs(self.transitions) do
			transition.cancel(self.transitions[k])
			self.transitions[k] = nil
		end
		display.remove(self.view)
	end

	----------------------------------------------------------
	return Viewable:init(o)
end

return class