-- Copyright 2013 Arman Darini
local scene = Storyboard.newScene()
local Viewable = require("game.viewable")
Utils.mergeTable(scene, Viewable.new())
local Level = require("game.level")

----------------------------------------------------------
function scene:get(event)
	Runtime:removeEventListener("get", self)
	
	if "200" == event.result then
		self:showLevel()
	else
	end
end

----------------------------------------------------------
function scene:getLevel()
	Runtime:addEventListener("get", self)
	self.level = Level.new()
	self.level:get()
end

----------------------------------------------------------
function scene:showLevel()
	self:showUI()

	self.level:show()
	self.view.content:insert(self.level.view)
	self.view.content.level = self.level.view
--	self.view.content.level.anchorChildren = true
	self.view.content.level.x = Game.centerX
	self.view.content.level.y = Game.centerY
	self.isStartedLevel = false

--	self:updateUI(self.level)
	Runtime:addEventListener("endLevel", self)
	Runtime:addEventListener("enterFrame", self)
--	self:startLevel()
end

----------------------------------------------------------
function scene:startLevel()
	self.time = nil
	self.view.ui.startGame.isVisible = false
	self.isStartedLevel = true
end

----------------------------------------------------------
function scene:endLevel(event)
	Runtime:removeEventListener("enterFrame", self)
	if "won" == event.result then
		p("WON")
		Storyboard.showOverlay("game.scenes.won", { isModal = true, params = {} })
	elseif "lost" == event.result then
		p("LOST")
		Storyboard.showOverlay("game.scenes.lost", { isModal = true, params = {} })
	end
end

----------------------------------------------------------
function scene:enterFrame(event)
	if self.isStartedLevel then
		self.time = self.time or event.time
		local deltaTime = event.time - self.time
		self.level:update(deltaTime)
		self.time = event.time
	end
	
	self:updateUI(self.level)
end

----------------------------------------------------------
function scene:showBackground()
	self.view.content.bg = display.newRect(self.view.content, Game.centerX, Game.centerY, Game.contentW, Game.contentH)
	self.view.content.bg:setFillColor(0)
end

----------------------------------------------------------
function scene:showHealth()
	self.view.ui.health = display.newGroup()
	self.view.ui:insert(self.view.ui.health)
	self.view.ui.health.x = Game.w - 100
	self.view.ui.health.y = Game.startY + 20
	
	self.view.ui.health.bg = display.newImage(self.view.ui.health, self.sheet, self.sheetInfo:getFrameIndex("ui_bar_1"))
	self.view.ui.health.bg.anchorX = 0
	
	self.view.ui.health.amount = display.newText(self.view.ui.health, "0", 0, 0, Game.font, 12)
	self.view.ui.health.amount:setFillColor(0)
	self.view.ui.health.amount.anchorX = 0
	self.view.ui.health.amount.x = 32
	self.view.ui.health.amount.y = -1
end

----------------------------------------------------------
function scene:showCoins()
	self.view.ui.coins = display.newGroup()
	self.view.ui:insert(self.view.ui.coins)
	self.view.ui.coins.x = Game.w - 40
	self.view.ui.coins.y = Game.startY + 20
	
	self.view.ui.coins.bg = display.newImage(self.view.ui.coins, self.sheet, self.sheetInfo:getFrameIndex("ui_bar_2"))
	self.view.ui.coins.bg.anchorX = 0
	
	self.view.ui.coins.amount = display.newText(self.view.ui.coins, "0", 0, 0, Game.font, 12)
	self.view.ui.coins.amount:setFillColor(0)
	self.view.ui.coins.amount.anchorX = 0
	self.view.ui.coins.amount.x = 25
	self.view.ui.coins.amount.y = -1
end

----------------------------------------------------------
function scene:showWave()
	self.view.ui.waves = display.newGroup()
	self.view.ui:insert(self.view.ui.waves)
	self.view.ui.waves.x = Game.w - 90
	self.view.ui.waves.y = Game.startY + 50

	self.view.ui.waves.bg = display.newImage(self.view.ui.waves, self.sheet, self.sheetInfo:getFrameIndex("ui_bar_3"))
	self.view.ui.waves.bg.anchorX = 0
	
	self.view.ui.waves.amount = display.newText(self.view.ui.waves, "0 / 0", 0, 0, Game.font, 12)
	self.view.ui.waves.amount:setFillColor(0)
	self.view.ui.waves.amount.anchorX = 0
	self.view.ui.waves.amount.x = 45
	self.view.ui.waves.amount.y = -3
end

----------------------------------------------------------
function scene:showStatusBar()
	display.setDefault("fillColor", { 0 })
	self.view.ui.statusBar = display.newGroup()
	self.view.ui:insert(self.view.ui.statusBar)
	self.view.ui.statusBar.x = Game.startX + 60
	self.view.ui.statusBar.y = Game.h - 9
	
	self.view.ui.statusBar.bg = display.newImage(self.view.ui.statusBar, self.sheet, self.sheetInfo:getFrameIndex("ui_bar_4"))
	self.view.ui.statusBar.bg.anchorX = 0
	self.view.ui.statusBar.bg.y = 3
	self.view.ui.statusBar.bg.x = -15
	
	self.view.ui.statusBar.name = display.newGroup()
	self.view.ui.statusBar:insert(self.view.ui.statusBar.name)
	self.view.ui.statusBar.name.amount = display.newText(self.view.ui.statusBar.name, "", 0, 0, Game.font, 10)
	self.view.ui.statusBar.name.amount.anchorX = 0

	self.view.ui.statusBar.health = display.newGroup()
	self.view.ui.statusBar:insert(self.view.ui.statusBar.health)
	self.view.ui.statusBar.health.caption = display.newText(self.view.ui.statusBar.health, "HEALTH :", 0, 0, Game.font, 10)
	self.view.ui.statusBar.health.caption.anchorX = 0
	self.view.ui.statusBar.health.amount = display.newText(self.view.ui.statusBar.health, "", 0, 0, Game.font, 10)
	self.view.ui.statusBar.health.amount.anchorX = 0
	self.view.ui.statusBar.health.amount.x = self.view.ui.statusBar.health.caption.width + 3

	self.view.ui.statusBar.damage = display.newGroup()
	self.view.ui.statusBar:insert(self.view.ui.statusBar.damage)
	self.view.ui.statusBar.damage.caption = display.newText(self.view.ui.statusBar.damage, "DAMAGE :", 0, 0, Game.font, 10)
	self.view.ui.statusBar.damage.caption.anchorX = 0
	self.view.ui.statusBar.damage.amount = display.newText(self.view.ui.statusBar.damage, "", 0, 0, Game.font, 10)
	self.view.ui.statusBar.damage.amount.anchorX = 0
	self.view.ui.statusBar.damage.amount.x = self.view.ui.statusBar.damage.caption.width + 3

	self.view.ui.statusBar.range = display.newGroup()
	self.view.ui.statusBar:insert(self.view.ui.statusBar.range)
	self.view.ui.statusBar.range.caption = display.newText(self.view.ui.statusBar.range, "RANGE :", 0, 0, Game.font, 10)
	self.view.ui.statusBar.range.caption.anchorX = 0
	self.view.ui.statusBar.range.amount = display.newText(self.view.ui.statusBar.range, "", 0, 0, Game.font, 10)
	self.view.ui.statusBar.range.amount.anchorX = 0
	self.view.ui.statusBar.range.amount.x = self.view.ui.statusBar.range.caption.width + 3

	self.view.ui.statusBar.speed = display.newGroup()
	self.view.ui.statusBar:insert(self.view.ui.statusBar.speed)
	self.view.ui.statusBar.speed.caption = display.newText(self.view.ui.statusBar.speed, "SPEED :", 0, 0, Game.font, 10)
	self.view.ui.statusBar.speed.caption.anchorX = 0
	self.view.ui.statusBar.speed.amount = display.newText(self.view.ui.statusBar.speed, "", 0, 0, Game.font, 10)
	self.view.ui.statusBar.speed.amount.anchorX = 0
	self.view.ui.statusBar.speed.amount.x = self.view.ui.statusBar.speed.caption.width + 3
	
	self:updateUI()
end

----------------------------------------------------------
function scene:showButton()
	self.view.ui.startGame = Widget.newButton
	{
		sheet = self.sheet,
		defaultFrame = self.sheetInfo:getFrameIndex("button_play"),
		overFrame = self.sheetInfo:getFrameIndex("button_play"),
		font = Game.font,
		fontSize = 15,
		labelColor = { default={ 1, 1, 1 }, over = { 1, 0, 0 } },
		onRelease = function()
			if true == Game.controlsBlocked then return end
			audio.play(Sounds.click, { channel = 1, onComplete = function()
				self:startLevel()
			end })
			return true
		end	
	}
	self.view.ui:insert(self.view.ui.startGame)
	self.view.ui.startGame.x = Game.startX + 35
	self.view.ui.startGame.y = Game.startY + 35
end

----------------------------------------------------------
function scene:updateUI(o)
	if o and o.health then self.view.ui.health.amount.text = o.health end
	if o and o.coins then self.view.ui.coins.amount.text = o.coins end
	if o and o.currentWave then self.view.ui.waves.amount.text = o.currentWave .. " / " .. o:getMaxWaves() end
	
	self.view.ui.statusBar.name.isVisible = false
	self.view.ui.statusBar.health.isVisible = false
	self.view.ui.statusBar.damage.isVisible = false
	self.view.ui.statusBar.range.isVisible = false
	self.view.ui.statusBar.speed.isVisible = false

	if o and o.statusBar then
		local space = 80
		for i = 1, #o.statusBar do
			if "name" == o.statusBar[i].type then
				self.view.ui.statusBar.name.isVisible = true
				self.view.ui.statusBar.name.amount.text = o.statusBar[i].value
			elseif "health" == o.statusBar[i].type then
				self.view.ui.statusBar.health.isVisible = true
				self.view.ui.statusBar.health.amount.text = o.statusBar[i].value
				self.view.ui.statusBar.health.x = (i - 1) * space
			elseif "damage" == o.statusBar[i].type then
				self.view.ui.statusBar.damage.isVisible = true
				self.view.ui.statusBar.damage.amount.text = o.statusBar[i].value
				self.view.ui.statusBar.damage.x = (i - 1) * space
			elseif "range" == o.statusBar[i].type then
				self.view.ui.statusBar.range.isVisible = true
				self.view.ui.statusBar.range.amount.text = o.statusBar[i].value
				self.view.ui.statusBar.range.x = (i - 1) * space
			elseif "speed" == o.statusBar[i].type then
				self.view.ui.statusBar.speed.isVisible = true
				self.view.ui.statusBar.speed.amount.text = o.statusBar[i].value / 1000
				self.view.ui.statusBar.speed.x = (i - 1) * space
			end
		end
	end
end

----------------------------------------------------------
function scene:showUI()
	self:showBackground()
	self:showHealth()
	self:showCoins()
	self:showWave()
	self:showStatusBar()
	self:showButton()
end

----------------------------------------------------------
function scene:createScene(event)
	self.timers = {}
	self.transitions = {}
	
	self.view.content = display.newGroup()
	self.view.ui = display.newGroup()
	self.view:insert(self.view.content)
	self.view:insert(self.view.ui)
end

----------------------------------------------------------
function scene:willEnterScene(event)
	self:getLevel()
end

----------------------------------------------------------
function scene:exitScene(event)
	Runtime:removeEventListener("endLevel", self)
	Runtime:removeEventListener("enterFrame", self)
	Runtime:removeEventListener("get", self)

	self.viewable:destroy()
end

----------------------------------------------------------
scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("exitScene", scene)

return scene