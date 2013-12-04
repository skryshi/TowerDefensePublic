--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
	content = {
--		width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
--		height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
--		scale = "letterBox",
		width = 320,
		height = 480,
		scale = "zoomEven",
		xAlign = "center",
		yAlign = "center",
		fps = 30,
		antialias = false,
		imageSuffix = {
			["-2x"] = 1.5,
			["-4x"] = 3.0,
		},

	},
	notification = {
		iphone = {
			types = {
				"badge", "sound", "alert"
			}
		}
	}
}

--[[
application = {
   content = {
      width = aspectRatio > 1.5 and 800 or math.ceil( 1200 / aspectRatio ),
      height = aspectRatio < 1.5 and 1200 or math.ceil( 800 * aspectRatio ),
      scale = "letterBox",
      fps = 30,

      imageSuffix = {
         ["-2x"] = 1.3,
      },
   },
}
--]]