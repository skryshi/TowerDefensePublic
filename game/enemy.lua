-- Copyright 2013 Arman Darini

local Viewable = require("game.viewable")

local class = {}
class.new = function(o)
	local Enemy = {}
	Utils.mergeTable(Enemy, Viewable.new())

	----------------------------------------------------------
	function Enemy:init(o)
		self.view.owner = self
		self.id = o.id
		self.path = o.path
		self.delay = o.delay
		self.elapsedTime = 0
		self.currentWaypoint = 2
		self.escaped = false
		self.distanceToEscape = 0
		for i = 1, #self.path - 1 do
			self.distanceToEscape = self.distanceToEscape + ((self.path[i].x - self.path[i+1].x)^2 + (self.path[i].y - self.path[i+1].y)^2)^0.5
		end
		Utils.mergeTable(self, class.config.enemies[self.id])

		self.view:addEventListener("tap", function(event) p("tap on enemy"); Runtime:dispatchEvent({ name = "tapEnemy", target = self }); return true end)
		return self
	end

	----------------------------------------------------------
	function Enemy:show(o)
		self.view.x = self.path[1].x
		self.view.y = self.path[1].y
		self.view.bg = display.newSprite(self.view, self.sheet, self.animations)
		self.view.bg:play()
	end

	----------------------------------------------------------
	function Enemy:update(deltaTime)
		self.elapsedTime = self.elapsedTime + deltaTime
		if self.elapsedTime < self.delay then return end

		if (self.path[self.currentWaypoint].x - self.view.x) < 0 then
			self.view.xScale = -1
		else
			self.view.xScale = 1
		end
		local d = ((self.path[self.currentWaypoint].x - self.view.x)^2 + (self.path[self.currentWaypoint].y - self.view.y)^2)^0.5
		local step = math.min(self.speed * deltaTime/1000, d)
		self.view.x = self.view.x + step * (self.path[self.currentWaypoint].x - self.view.x)/d
		self.view.y = self.view.y + step * (self.path[self.currentWaypoint].y - self.view.y)/d
		if d < 2 and self.currentWaypoint < #self.path then
			self.currentWaypoint = self.currentWaypoint + 1
		elseif d < 2 then
			self.escaped = true
		end
		self.distanceToEscape = self.distanceToEscape - step
	end
	
	----------------------------------------------------------
	function Enemy:isDead()
		return self.health <= 0
	end
	
	----------------------------------------------------------
	function Enemy:isEscaped()
		return self.escaped
	end

	----------------------------------------------------------
	function Enemy:destroy()
		self.viewable:destroy()
		display.remove(self.view)
	end
	
	----------------------------------------------------------
	return Enemy:init(o)
end

class.config = {
	enemies = {
		[1] = { name = "Spork", health = 5, speed = 20, coins = 20, damage = 1, animations = { name = "default", start = 1, count = 20, time = 1000 } },
		[2] = { name = "Mama", health = 10, speed = 25, coins = 40, damage = 1, animations = { name = "default", start = 21, count = 20, time = 1000 } },
		[3] = { name = "Elvis", health = 20, speed = 15, coins = 80, damage = 1, animations = { name = "default", start = 41, count = 20, time = 1000 } },
	}
}

return class
