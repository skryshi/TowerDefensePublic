-- Copyright 2013 Arman Darini

local Viewable = require("game.viewable")

local class = {}
class.new = function(o)
	local Tower = {}
	Utils.mergeTable(Tower, Viewable.new())

	----------------------------------------------------------
	function Tower:init(o)
		self.view.owner = self
		self.state = 0
		self.particleManager = o.particleManager
		self.rechargeAge = 0
		Utils.mergeTable(self, class.config.towers[self.state])

		self.animations =
		{
			[0] = {
				{ name = "passive", frames = { 61 } },
			},
			[1] = {
				{ name = "passive", start = 67, count = 2, time = 400 },
				{ name = "active", start = 67, count = 16, time = 3200, loopCount = 1 },
			},
			[2] = {
				{ name = "passive", start = 100, count = 20, time = 4000 },
				{ name = "active", start = 120, count = 5, time = 1000, loopCount = 1 },
			},
			[3] = {
				{ name = "passive", start = 150, count = 20, time = 4000 },
				{ name = "active", start = 170, count = 8, time = 1600, loopCount = 1 },
			},
			[4] = {
				{ name = "passive", start = 83, count = 2, time = 500 },
				{ name = "active", start = 83, count = 17, time = 3400, loopCount = 1 },
			},
			[5] = {
				{ name = "passive", start = 125, count = 20, time = 4000 },
				{ name = "active", start = 145, count = 5, time = 1000, loopCount = 1 },
			},
		}
		
		self.view:addEventListener("tap", function(event) p("tap on tower"); Runtime:dispatchEvent({ name = "tapTower", target = self }); return true end)
		return self
	end

	----------------------------------------------------------
	function Tower:createSlowBomb(target, enemies)
		local view = display.newImage(self.sheet, self.sheetInfo:getFrameIndex("projectile_03"))
--		local view = display.newCircle(0, 0, 5)
--		view:setFillColor(0,0,1)
		view.x = self.view.x
		view.y = self.view.y
		local onImpact = function()
			for _, enemy in pairs(enemies) do
				local d = ((view.x - enemy.view.x)^2 + (view.y - enemy.view.y)^2)^0.5
				if d <= self.projectileExplosionRadius then
					enemy.speed = enemy.speed * 0.5
					print("enemy slowed, id=" .. enemy.id .. " speed=" .. enemy.speed)
					timer.performWithDelay(self.projectileEffectDuration, 
						function()
							if nil ~= enemy then
								enemy.speed = enemy.speed * 2
							end
						end
					)
				end
			end
			transition.to(view, { time = 200, xScale = self.projectileExplosionRadius / 5, yScale = self.projectileExplosionRadius / 5, alpha = 0.5, onComplete = function() display.remove(view) end })
		end
		return { goal = { x = target.view.x, y = target.view.y }, speed = self.projectileSpeed, maxAge = self.projectileMaxAge, view = view, onImpact = onImpact }
	end
	
	----------------------------------------------------------
	function Tower:createBomb(target, enemies)
		local view = display.newImage(self.sheet, self.sheetInfo:getFrameIndex("projectile_02"))
--		local view = display.newCircle(0, 0, 5)
--		view:setFillColor(1,0,0)
		view.x = self.view.x
		view.y = self.view.y
		local onImpact = function()
			for _, enemy in pairs(enemies) do
				local d = ((view.x - enemy.view.x)^2 + (view.y - enemy.view.y)^2)^0.5
				if d <= self.projectileExplosionRadius then
					enemy.health = enemy.health - self.damage
					print("enemy bomb hit, id=" .. enemy.id .. " damage=" .. self.damage .. " health=" .. enemy.health)
				end
			end
			transition.to(view, { time = 200, xScale = self.projectileExplosionRadius / 5, yScale = self.projectileExplosionRadius / 5, alpha = 0.5, onComplete = function() display.remove(view) end })
		end
		return { goal = { x = target.view.x, y = target.view.y }, speed = self.projectileSpeed, maxAge = self.projectileMaxAge, view = view, onImpact = onImpact }
	end
	
	----------------------------------------------------------
	function Tower:createMissile(target)
		local view = display.newImage(self.sheet, self.sheetInfo:getFrameIndex("projectile_01"))
--		local view = display.newCircle(0, 0, 5)
		view.x = self.view.x
		view.y = self.view.y
		local onImpact = function()
			target.health = target.health - self.damage
			print("enemy missile hit, id=" .. target.id .. " damage=" .. self.damage .. " health=" .. target.health)
			display.remove(view)
		end
		return { goal = target.view, speed = self.projectileSpeed, maxAge = self.projectileMaxAge, view = view, onImpact = onImpact }
	end
	
	----------------------------------------------------------
	function Tower:update(enemies, deltaTime)
		self.rechargeAge = self.rechargeAge + deltaTime
		local attacked = false
		for _, enemy in pairs(enemies) do
			local d = ((self.view.x - enemy.view.x)^2 + (self.view.y - enemy.view.y)^2)^0.5
			if self.rechargeAge >= self.rateOfFire and d <= self.radius then
				attacked = true
				self.rechargeAge = 0
				if "missile" == self.type then
					self.particleManager:add(self:createMissile(enemy))
				elseif "bomb" == self.type then
					self.particleManager:add(self:createBomb(enemy, enemies))
				elseif "slowBomb" == self.type then
					self.particleManager:add(self:createSlowBomb(enemy, enemies))
				end
			end
		end
		if attacked and "passive" == self.view.bg.sequence then
			p("setting active sequence")
			self.view.bg:setSequence("active")
			self.view.bg:play()
		elseif not attacked and "active" == self.view.bg.sequence and self.rechargeAge > 3000 then
--			p("setting passive sequence")
--			self.view.bg:setSequence("passive")
--			self.view.bg:play()
		end
	end
	
	----------------------------------------------------------
	function Tower:show()
		display.remove(self.view.bg)
		self.view.bg = display.newSprite(self.view, self.sheet, self.animations[self.state])
		if 0 ~= self.state then
			self.view.bg.anchorY = 0.9
		end
		self.view.bg:setSequence("passive")
		self.view.bg:play()
		self.view.bg:addEventListener("sprite", self)
	end
	
	----------------------------------------------------------
	function Tower:sprite(event)
		if "ended" == event.phase then
			self.view.bg:setSequence("passive")
			self.view.bg:play()
		end
	end

	----------------------------------------------------------
	function Tower:upgrade(state)
		self.state = state
		Utils.mergeTable(self, class.config.towers[self.state])
		self:show()
	end
	
	----------------------------------------------------------
	function Tower:sell()
		self.state = 0
		Utils.mergeTable(self, class.config.towers[self.state])
		self:show()
	end

	----------------------------------------------------------
	function Tower:isUpgradable()
		return nil ~= class.config.upgrades[self.state]
	end

	----------------------------------------------------------
	function Tower:getUpgrades()
		return class.config.upgrades[self.state] or {}
	end

	----------------------------------------------------------
	function Tower:upgradeCost(state)
		return class.config.towers[state].cost
	end
	
	----------------------------------------------------------
	function Tower:isSalable()
		return 0 ~= self.state
	end

	----------------------------------------------------------
	function Tower:saleValue()
		return math.round(self.cost * 0.5)
	end

	----------------------------------------------------------
	return Tower:init(o)
end

class.config = {
	upgrades = {
		[0] = { 1, 2, 3 },
		[1] = { 4 },
		[2] = { 5 }
	},
	towers = {
		[0] = { cost = 0, name = "", type = "base", rateOfFire = 0, radius = 0, damage = 0, projectileSpeed = 0, projectileMaxAge = 0, projectileExplosionRadius = 0, projectileEffectDuration = 0, uiPosition = 1, icon = "" },
		[1] = { cost = 60, name = "Straight Shooter", type = "missile", rateOfFire = 2000, radius = 100, damage = 2, projectileSpeed = 200, projectileMaxAge = 3000, projectileExplosionRadius = 0, projectileEffectDuration = 0, uiPosition = 1, icon = "tower_icon_1" },
		[2] = { cost = 130, name = "Bomber", type = "bomb", rateOfFire = 4000, radius = 75, damage = 4, projectileSpeed = 200, projectileMaxAge = 3000, projectileExplosionRadius = 30, projectileEffectDuration = 0, uiPosition = 3, icon = "tower_icon_2" },
		[3] = { cost = 100, name = "Slow Down", type = "slowBomb", rateOfFire = 3000, radius = 100, damage = 0, projectileSpeed = 200, projectileMaxAge = 3000, projectileExplosionRadius = 40, projectileEffectDuration = 2000, uiPosition = 5, icon = "tower_icon_3" },
		[4] = { cost = 120, name = "Straight Shooter II", type = "missile", rateOfFire = 1500, radius = 110, damage = 3, projectileSpeed = 300, projectileMaxAge = 3000, projectileExplosionRadius = 0, projectileEffectDuration = 0, uiPosition = 2, icon = "tower_upgrade" },
		[5] = { cost = 260, name = "Bomber II", type = "bomb", rateOfFire = 3500, radius = 100, damage = 6, projectileSpeed = 200, projectileMaxAge = 3000, projectileExplosionRadius = 35, projectileEffectDuration = 0, uiPosition = 2, icon = "tower_upgrade" },
	}
}

return class
