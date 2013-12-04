-- Copyright 2013 Arman Darini

local class = {}
class.new = function(o)
	local Game = {}

	----------------------------------------------------------
	function Game:init(o)
		self.debug = false
		self.w = display.actualContentWidth
		self.h = display.actualContentHeight
		self.contentW = display.contentWidth
		self.contentH = display.contentHeight
		self.centerX = display.contentCenterX
		self.centerY = display.contentCenterY
		self.startX = self.centerX - self.w * 0.5
		self.startY = self.centerY - self.h * 0.5
--		font = "AveriaLibre-Bold"
		self.font = "Cabin-Regular"
		self.fontBold = "Cabin-Bold"
		self.controlsBlocked = false

		return self
	end

	----------------------------------------------------------
	function Game:removeSelf()
	end

	----------------------------------------------------------
	return Game:init(o)
end

return class
