-- Copyright 2013 Arman Darini
local scene = Storyboard.newScene()
local Viewable = require("game.viewable")
Utils.mergeTable(scene, Viewable.new())

----------------------------------------------------------
function scene:showBackground()
	self.view.content.bg = display.newRect(self.view.content, Game.centerX, Game.centerY, Game.contentW, Game.contentH)
	self.view.content.bg:setFillColor(1)
end

----------------------------------------------------------
function scene:showHeader()
	self.view.ui.header = display.newText(self.view.ui, "YOU LOST", 0, 0, Game.font, 50)
	self.view.ui.header:setFillColor(1, 0, 0)
	self.view.ui.header.y = -30
end

----------------------------------------------------------
function scene:showButton()
	self.view.ui.startGame = Widget.newButton
	{
		label = "Play Again",
		font = Game.font,
		fontSize = 30,
		labelColor = { default = { 0, 0, 0 }, over = { 1, 0, 0 } },
		onRelease = function()
			if true == Game.controlsBlocked then return end
			audio.play(Sounds.click, { channel = 1, onComplete = function()
--				Storyboard.hideOverlay()
				Storyboard.purgeScene("game.scenes.play")
				Storyboard.gotoScene("game.scenes.play")
			end })
			return true
		end	
	}
	self.view.ui:insert(self.view.ui.startGame)
	self.view.ui.startGame.x = 0
	self.view.ui.startGame.y = 40
end

----------------------------------------------------------
function scene:createScene(event)
	self.timers = {}
	self.transitions = {}
	
	self.view.content = display.newGroup()
	self.view.ui = display.newGroup()
	self.view:insert(self.view.content)
	self.view:insert(self.view.ui)
	self.view.ui.x = Game.centerX
	self.view.ui.y = Game.centerY	
end

----------------------------------------------------------
function scene:willEnterScene(event)
	self:showBackground()
	self:showHeader()
	self:showButton()
end

----------------------------------------------------------
function scene:exitScene(event)
	self.viewable:destroy()
end

----------------------------------------------------------
scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("exitScene", scene)

return scene