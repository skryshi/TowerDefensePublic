-- Copyright 2013 Arman Darini

helpers = {
	----------------------------------------------------------
	convertExpToLevel = function(exp)
		for i = 1, #Game.exp do
			if exp < Game.exp[i] then return i - 1 end
		end
	end,
	
	----------------------------------------------------------
	getPlayerLevel = function()
		return helpers.convertExpToLevel(Player.exp)
	end,

	----------------------------------------------------------
	expSinceLevel = function()
		return Player.exp - Game.exp[helpers.getPlayerLevel()]
	end,

	----------------------------------------------------------
	percentLevelComplete = function()
		return helpers.expSinceLevel() / (Game.exp[helpers.getPlayerLevel() + 1] - Game.exp[helpers.getPlayerLevel()])
	end,
	
	----------------------------------------------------------
	computeStars = function(score, level)
		i = 0
		while i < #Game.levels[level].stars and score >= Game.levels[level].stars[i + 1] do
			i = i + 1
		end
		return i
	end,
	
	----------------------------------------------------------
	isLevelUnlocked = function(level)
		if 1 == level or Player.levels[level].highScore > Game.levels[level].stars[1] or Player.levels[level - 1].highScore > Game.levels[level - 1].stars[1] then
			return true
		else
			return false
		end
	end,

	----------------------------------------------------------
	setFillColor = function(object, o)
		if "table" == type(o) then
			object:setFillColor(o[1], o[2], o[3])
		else
			if 1 == o then
				object:setFillColor(255, 0, 0)
			elseif 2 == o then
				object:setFillColor(0, 255, 0)
			elseif 3 == o then
				object:setFillColor(0, 0, 255)
			elseif 4 == o then
				object:setFillColor(255, 255, 0)
			elseif 5 == o then
				object:setFillColor(0, 255, 255)
			elseif 6 == o then
				object:setFillColor(255, 0, 255)
			elseif 7 == o then
				object:setFillColor(128, 0, 0)
			elseif 8 == o then
				object:setFillColor(0, 128, 0)
			elseif 9 == o then
				object:setFillColor(0, 0, 128)
			elseif 10 == o then
				object:setFillColor(128, 128, 128)
			else
				object:setFillColor(255, 255, 255)
			end
		end
	end,

	----------------------------------------------------------
	printCoordinates = function(displayObject)
		print("x,y="..displayObject.x..", "..displayObject.y, "xOr, yOr="..displayObject.xOrigin..", "..displayObject.yOrigin, "xRef, yRef="..displayObject.xReference..", "..displayObject.yReference, "h, w="..displayObject.width..", "..displayObject.height)
	end,

	----------------------------------------------------------
	formatAsTime = function(seconds)
		return string.format("%01d:%02d", Math.floor(seconds / 60), (seconds % 60))
	end,
}

return helpers