-- Copyright 2013 Arman Darini

local Tower = require("game.tower")
local Enemy = require("game.enemy")
local ParticleManager = require("game.particle_manager")
local Persistent = require("game.persistent")
local Viewable = require("game.viewable")

local class = {}
class.new = function(o)
	local Level = {}
	Utils.mergeTable(Level, Persistent.new())
	Utils.mergeTable(Level, Viewable.new())
	
	----------------------------------------------------------
	function Level:init(o)
		self.view.owner = self
		self._persistent.class = "level"
		self._persistent.board = nil
		self.score = 0
		self.health = 0
		self.coins = 0
		self.currentWave = 0
		self.completed = false
		self.elapsedTime = 0
		self.towers	= {}
		self.enemies = {}
		self.towerSelected = nil
		self.particleManager = ParticleManager.new()
		self.statusBar = {}

		return self
	end

	----------------------------------------------------------
	function Level:get()
--		self:getFromLocal('levels/1.json')
		self:mock()
	end
	
	----------------------------------------------------------
	function Level:mock()
		local level = {
			coins = 100,
			health = 10,
			background = "1.png",
			paths = {
				{	{ x = 5, y = -180 }, { x = -5, y = -140 }, { x = -30, y = -130 }, { x = -115, y = -105 }, { x = -135, y = -90 }, { x = -135, y = -70 }, { x = -90, y = -45 }, { x = -62, y = 0 }, { x = -80, y = 20 }, { x = -145, y = 60 }, { x = -170, y = 90 }, { x = -175, y = 130 }, { x = -165, y = 180 }, },
				{	{ x = 5, y = -180 }, { x = -5, y = -140 }, { x = -30, y = -130 }, { x = -115, y = -105 }, { x = -135, y = -90 }, { x = -135, y = -70 }, { x = -90, y = -45 }, { x = 40, y = -40 }, { x = 80, y = -30 }, { x = 110, y = 30 }, { x = 160, y = 40 }, { x = 185, y = 65 }, { x = 170, y = 110 }, { x = 170, y = 180 }, },
			},
			bases = { { x = -80, y = -78 }, { x = -10, y = 5 }, { x = 150, y = 0 }, { x = 40, y = -80 }, { x = -110, y = 110 } },
			maxTowerLevels = { 1, 1, 1 },
			waves = {
				{
					delay = 1000,
					enemies = {
						{ id = 1, delay = 0, path = 1 },
						{ id = 1, delay = 3000, path = 1 },
						{ id = 1, delay = 6000, path = 1 },
					}
				},
				{
					delay = 25000,
					enemies = {
						{ id = 1, delay = 0, path = 1 },
						{ id = 1, delay = 1000, path = 1 },
						{ id = 1, delay = 2000, path = 1 },
						{ id = 1, delay = 3000, path = 1 },
					}
				},
				{
					delay = 50000,
					enemies = {
						{ id = 1, delay = 0, path = 2 },
						{ id = 1, delay = 1000, path = 2 },
						{ id = 2, delay = 4000, path = 1 },
						{ id = 2, delay = 5000, path = 1 },
					}
				},
				{
					delay = 70000,
					enemies = {
						{ id = 2, delay = 0, path = 1 },
						{ id = 2, delay = 1000, path = 2 },
						{ id = 1, delay = 3000, path = 1 },
						{ id = 1, delay = 4000, path = 2 },
						{ id = 3, delay = 6000, path = 1 },
						{ id = 3, delay = 7000, path = 2 },
					}
				},
				{
					delay = 90000,
					enemies = {
						{ id = 2, delay = 0, path = 1 },
						{ id = 2, delay = 1000, path = 1 },
						{ id = 3, delay = 3000, path = 1 },
						{ id = 3, delay = 4000, path = 2 },
						{ id = 2, delay = 5000, path = 2 },
						{ id = 2, delay = 6000, path = 2 },
						{ id = 3, delay = 8000, path = 1 },
						{ id = 3, delay = 9000, path = 2 },
					}
				}
			}
		}
		
		Utils.mergeTable(self._persistent, level)
		--	put all persistent data into main namespace
		Utils.mergeTable(self, self._persistent)
		
		for i = 1, #self.waves do
			self.waves[i].isStarted = false
		end
		
		response = { name = "get", type = self._persistent.type, result = "200" }
		Runtime:dispatchEvent(response)
		p(response)
	end
	
	----------------------------------------------------------
	function Level:drawPaths()
		self.view.ui.paths = display.newGroup()
		self.view.ui:insert(self.view.ui.paths)
		for i = 1, #self.paths do
			for j = 1, #self.paths[i] - 1 do
				local line = display.newLine(self.view.ui.paths, self.paths[i][j].x, self.paths[i][j].y, self.paths[i][j+1].x, self.paths[i][j+1].y)
				table.insert(self.view.ui.paths, line)
			end
		end
	end
	
	----------------------------------------------------------
	function Level:getUICoordinates(position)
		local x, y
		if 1 == position then
			x = -20
			y = -20
		elseif 2 == position then
			x = 0
			y = -30
		elseif 3 == position then
			x = 20
			y = -20
		elseif 4 == position then
			x = 30
			y = 0
		elseif 5 == position then
			x = 20
			y = 20
		elseif 6 == position then
			x = 0
			y = 30
		elseif 7 == position then
			x = -20
			y = 20
		elseif 8 == position then
			x = -30
			y = 0
		end
		
		return x, y
	end

	----------------------------------------------------------
	function Level:show(o)
		p("show")
		self.view.anchorChildren = true
		
		self.view.bg = display.newImageRect(self.view, "assets/images/levels/" .. self.background, Game.contentW, Game.contentH)
		self.view.bg2 = display.newRect(self.view, Game.centerX, Game.centerY, 480, 340)
		self.view.bg2:setFillColor(1,0, 0)
		self.view.bg2.alpha = 0.1
		self.view.bg.x = Game.centerX
		self.view.bg.y = Game.centerY
		
		self.view.enemies = display.newGroup()
		self.view:insert(self.view.enemies)
		self.view.enemies.x = Game.centerX
		self.view.enemies.y = Game.centerY
		
		self.view.towers = display.newGroup()
		self.view:insert(self.view.towers)
		for i = 1, #self.bases do
			self.towers[i] = Tower.new({ particleManager = self.particleManager })
			self.towers[i]:show()
			self.view.towers:insert(self.towers[i].view)
			self.towers[i].view.x = self.bases[i].x
			self.towers[i].view.y = self.bases[i].y
		end
		self.view.towers.x = Game.centerX
		self.view.towers.y = Game.centerY

		self.view:insert(self.particleManager.view)
		self.particleManager.view.x = Game.centerX
		self.particleManager.view.y = Game.centerY

		self:showUI()
--		self:drawPaths()
		
		self.view:addEventListener("tap", self)
		Runtime:addEventListener("tapTower", self)
		Runtime:addEventListener("tapEnemy", self)
	end

	----------------------------------------------------------
	function Level:showUI()
		self.view.ui = display.newGroup()
		self.view:insert(self.view.ui)
		self.view.ui.x = Game.centerX
		self.view.ui.y = Game.centerY
		self.view.ui.towerMenu = display.newGroup()
		self.view.ui:insert(self.view.ui.towerMenu)
--		self.view.ui.towerMenu.x = 0
--		self.view.ui.towerMenu.y = 0

		self.view.ui.towerMenu.bg = display.newImage(self.view.ui.towerMenu, self.sheet, self.sheetInfo:getFrameIndex("tower_icon_ring"))

		self.view.ui.towerMenu.icons = display.newGroup()
		self.view.ui.towerMenu:insert(self.view.ui.towerMenu.icons)
		for i = 1, #Tower.config.towers do
			table.insert(self.view.ui.towerMenu.icons, i, display.newGroup())
			self.view.ui.towerMenu.icons:insert(self.view.ui.towerMenu.icons[i])
			self.view.ui.towerMenu.icons[i].enabled = display.newImage(self.view.ui.towerMenu.icons[i], self.sheet, self.sheetInfo:getFrameIndex(Tower.config.towers[i].icon .. "_enabled"))
			self.view.ui.towerMenu.icons[i].disabled = display.newImage(self.view.ui.towerMenu.icons[i], self.sheet, self.sheetInfo:getFrameIndex(Tower.config.towers[i].icon .. "_disabled"))
			self.view.ui.towerMenu.icons[i].selected = display.newImage(self.view.ui.towerMenu.icons[i], self.sheet, self.sheetInfo:getFrameIndex("tower_icon_check"))
			self.view.ui.towerMenu.icons[i].caption = display.newText(self.view.ui.towerMenu.icons[i], Tower.config.towers[i].cost, 0, 11, Game.fontBold, 6)
			self.view.ui.towerMenu.icons[i].caption:setFillColor(0, 0, 1)
			
			self.view.ui.towerMenu.icons[i].enabled.towerState = i
			self.view.ui.towerMenu.icons[i].enabled:addEventListener("tap", function(event) self:tapSelectTower(event); return true end)

			self.view.ui.towerMenu.icons[i].selected.towerState = i
			self.view.ui.towerMenu.icons[i].selected:addEventListener("tap", function(event) self:tapUpgradeTower(event); return true end)

			self.view.ui.towerMenu.icons[i].x, self.view.ui.towerMenu.icons[i].y = self:getUICoordinates(Tower.config.towers[i].uiPosition)
		end

		self.view.ui.towerMenu.areasOfEffect = display.newGroup()
		self.view.ui.towerMenu:insert(self.view.ui.towerMenu.areasOfEffect)
		for i = 0, #Tower.config.towers do
			local aoe = display.newImage(self.view.ui.towerMenu.areasOfEffect, self.sheet, self.sheetInfo:getFrameIndex("tower_radius"))
			aoe.width = Tower.config.towers[i].radius * 2
			aoe.height = Tower.config.towers[i].radius * 2
			table.insert(self.view.ui.towerMenu.areasOfEffect, i, aoe)
		end

		self.view.ui.towerMenu.icons.sell = display.newGroup()
		self.view.ui.towerMenu.icons:insert(self.view.ui.towerMenu.icons.sell)
		self.view.ui.towerMenu.icons.sell.enabled = display.newImage(self.view.ui.towerMenu.icons.sell, self.sheet, self.sheetInfo:getFrameIndex("tower_sell"))
		self.view.ui.towerMenu.icons.sell.selected = display.newImage(self.view.ui.towerMenu.icons.sell, self.sheet, self.sheetInfo:getFrameIndex("tower_icon_check"))
		self.view.ui.towerMenu.icons.sell.caption = display.newText(self.view.ui.towerMenu.icons.sell, "", 0, 11, Game.fontBold, 6)
		self.view.ui.towerMenu.icons.sell.caption:setFillColor(0, 0, 1)
		self.view.ui.towerMenu.icons.sell.x, self.view.ui.towerMenu.icons.sell.y = self:getUICoordinates(6)
		self.view.ui.towerMenu.icons.sell.enabled:addEventListener("tap", function(event) self:tapSelectSell(event); return true end)
		self.view.ui.towerMenu.icons.sell.selected:addEventListener("tap", function(event) self:tapSellTower(event); return true end)
		
		self.view.ui.towerMenu.isVisible = false
	end
	
	----------------------------------------------------------
	function Level:hideUI()
		for i = 1, #Tower.config.towers do
			self.view.ui.towerMenu.icons[i].enabled.isVisible = false
			self.view.ui.towerMenu.icons[i].disabled.isVisible = false
			self.view.ui.towerMenu.icons[i].selected.isVisible = false
			self.view.ui.towerMenu.icons[i].caption.isVisible = false
			self.view.ui.towerMenu.areasOfEffect[i].isVisible = false
		end
		self.view.ui.towerMenu.icons.sell.enabled.isVisible = false
		self.view.ui.towerMenu.icons.sell.selected.isVisible = false
		self.view.ui.towerMenu.icons.sell.caption.isVisible = false
	end
	
	----------------------------------------------------------
	function Level:tap(event)
		p("Level:tap")
		self.towerSelected = nil
		self.view.ui.towerMenu.isVisible = false
		self.statusBar = {}
	end
	
	----------------------------------------------------------
	function Level:tapEnemy(event)
		self.enemySelected = event.target
		self.statusBar = { { type = "name", value = self.enemySelected.name }, { type = "health", value = self.enemySelected.health }, { type = "damage", value = self.enemySelected.damage }, { type = "speed", value  = self.enemySelected.speed } }
	end
	
	----------------------------------------------------------
	function Level:tapTower(event)
		p("Level:tapTower")
		self.towerSelected = event.target
		self.view.ui.towerMenu.isVisible = true
		self.view.ui.towerMenu.x = self.towerSelected.view.x
		self.view.ui.towerMenu.y = self.towerSelected.view.y
		self:hideUI()
		local upgrades = self.towerSelected:getUpgrades()
		for i = 1, #upgrades do
			if self.coins >= self.towerSelected:upgradeCost(upgrades[i]) then
				self.view.ui.towerMenu.icons[upgrades[i]].enabled.isVisible = true
			else
				self.view.ui.towerMenu.icons[upgrades[i]].disabled.isVisible = true
			end
			self.view.ui.towerMenu.icons[upgrades[i]].caption.isVisible = true
		end
		if self.towerSelected:isSalable() then
			self.view.ui.towerMenu.icons.sell.enabled.isVisible = true
			self.view.ui.towerMenu.icons.sell.caption.isVisible = true
		end
		self.view.ui.towerMenu.areasOfEffect[self.towerSelected.state].isVisible = true
		
		if self.towerSelected.name ~= "" then
			self.statusBar = { { type = "name", value = self.towerSelected.name }, { type = "damage", value = self.towerSelected.damage }, { type = "range", value = self.towerSelected.radius }, { type = "speed", value  = self.towerSelected.rateOfFire } }
		else
			self.statusBar = {}
		end
	end
	
	----------------------------------------------------------
	function Level:tapSelectTower(event)
		p("Level:tapSelectTower")
		self:hideUI()
		local upgrades = self.towerSelected:getUpgrades()
		for i = 1, #upgrades do
			if self.coins >= self.towerSelected:upgradeCost(upgrades[i]) then
				self.view.ui.towerMenu.icons[upgrades[i]].enabled.isVisible = true
			else
				self.view.ui.towerMenu.icons[upgrades[i]].disabled.isVisible = true
			end
			self.view.ui.towerMenu.icons[upgrades[i]].caption.isVisible = true
		end
		self.view.ui.towerMenu.icons[event.target.towerState].selected.isVisible = true
		self.view.ui.towerMenu.areasOfEffect[event.target.towerState].isVisible = true

		local tower = Tower.config.towers[event.target.towerState]
		self.statusBar = { { type = "name", value = tower.name }, { type = "damage", value = tower.damage }, { type = "range", value = tower.radius }, { type = "speed", value  = tower.rateOfFire } }
	end

	----------------------------------------------------------
	function Level:tapUpgradeTower(event)
		p("Level:tapBuildTower")
		self.coins = self.coins - self.towerSelected:upgradeCost(event.target.towerState)
		self.towerSelected:upgrade(event.target.towerState)
		self.view.ui.towerMenu.icons.sell.caption.text = self.towerSelected:saleValue()
		self.towerSelected = nil
		self.view.ui.towerMenu.isVisible = false
		self.statusBar = {}
	end

	----------------------------------------------------------
	function Level:tapSelectSell(event)
		self:hideUI()
		self.view.ui.towerMenu.icons.sell.selected.isVisible = true
		self.view.ui.towerMenu.icons.sell.caption.isVisible = true
		self.view.ui.towerMenu.areasOfEffect[self.towerSelected.state].isVisible = true
		p("Level:tapSelectSell")
	end
	
	----------------------------------------------------------
	function Level:tapSellTower(event)
		p("Level:tapSellTower")
		self.coins = self.coins + self.towerSelected:saleValue()
		self.towerSelected:sell()
		self.towerSelected = nil
		self.view.ui.towerMenu.isVisible = false
		self.statusBar = {}
	end

	----------------------------------------------------------
	function Level:updateTowers(deltaTime)
		for i = 1, #self.towers do
			self.towers[i]:update(self.enemies, deltaTime)
		end
	end

	----------------------------------------------------------
	function Level:removeEnemies()
		for i = #self.enemies, 1, -1 do
			if self.enemies[i]:isDead() then
				self.coins = self.coins + self.enemies[i].coins
				self.enemies[i]:destroy()
				table.remove(self.enemies, i)
			elseif self.enemies[i]:isEscaped() then
				self.health = self.health - self.enemies[i].damage
				p(self.health)
				self.enemies[i]:destroy()
				table.remove(self.enemies, i)
			end
		end
		
		if 0 == #self.enemies and self.currentWave == #self.waves then
			Runtime:dispatchEvent( { name = "endLevel", result = "won" })
		end
	end

	----------------------------------------------------------
	function Level:updateEnemies(deltaTime)
		table.sort(self.enemies, function(e1, e2) return e1.distanceToEscape < e2.distanceToEscape end)
		for i = 1, #self.enemies do
			self.enemies[i].view:toBack()
			self.enemies[i]:update(deltaTime)
		end
	end

	----------------------------------------------------------
	function Level:startWave()
--		p(self.elapsedTime)
		for i = 1, #self.waves do
			if false == self.waves[i].isStarted and self.elapsedTime >= self.waves[i].delay then
				p("starting wave=" .. i)
				self.currentWave = self.currentWave + 1
				self.waves[i].isStarted = true
				for j = 1, #self.waves[i].enemies do
					local options = self.waves[i].enemies[j]
					options.path = self.paths[options.path]
					self.enemies[#self.enemies + 1] = Enemy.new( options )
					self.enemies[#self.enemies]:show()
					self.view.enemies:insert(self.enemies[#self.enemies].view)
				end
			end
		end
	end

	----------------------------------------------------------
	function Level:update(deltaTime)
		self.elapsedTime = self.elapsedTime + deltaTime
		
		self:startWave()
		self.particleManager:update(deltaTime)
		self:updateEnemies(deltaTime)
		self:updateTowers(deltaTime)
		self:removeEnemies()
		
		if self.health <= 0 then
			Runtime:dispatchEvent({ name = "endLevel", result = "lost" })
		end
	end
	
	----------------------------------------------------------
	function Level:getMaxWaves()
		return self.waves and #self.waves or 0
	end

	----------------------------------------------------------
	function Level:destroy()
		Runtime:removeEventListener("tapTower", self)
		Runtime:removeEventListener("tapEnemy", self)
		self.viewable:destroy()
		self.persistent:destroy()
	end
	
	----------------------------------------------------------
	return Level:init(o)
end

return class


