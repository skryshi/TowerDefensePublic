-- Copyright 2013 Arman Darini

display.setStatusBar(display.HiddenStatusBar)

-- these are used almost everywhere, so make them global
Utils = require("lib.utils")
Math = require("lib.math2")
Helpers = require("lib.helpers")
Widget = require("widget")
Json = require("json")
Storyboard = require("storyboard")
Storyboard.purgeOnSceneChange = true

Game = require("game.game").new()
User = require("game.user").new()

--	init sounds and music
Sounds = {
	click = audio.loadSound("assets/sounds/click.mp3"),
}
--Music = audio.loadStream("sounds/theme_song.mp3")
--audio.play(Music, { channel = 2, loops=-1, fadein=1000 })

-- add debug
if Game.debug then
	timer.performWithDelay(1000, Utils.printMemoryUsed, 0)
end

Storyboard.gotoScene("game.scenes.play", { params = {} })