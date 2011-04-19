function love.load()
	font = love.graphics.newImageFont("data/confont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)
	
	-- Array of wall/ground tiles
	tiles = {}
	for i=1, 172 do
		tiles[i] = love.graphics.newImage("data/tiles/tile"..i..".png")
	end
	
	sprites = {}
	for j=1, 33 do
		sprites[j] = love.graphics.newImage("data/sprites/spr"..j..".png")
	end
	
	isInitializing = false
	isReadyToEdit = true
	isReading = false
	isWriting = false
	isSaving = false
	
	dialogCooldown = 90
	inputCooldown = 10
	
	shifting = false
	
	cursor = {}
	cursor.x = 1
	cursor.y = 1
	cursor.isInDialog = false
	
	sizeOfObj = 16
	scaleOfObj = sizeOfObj / 64.0
	
	sizeOfMapX = 72			-- this might change?
	sizeOfMapY = 40			-- ditto
	
	offsetX = 0
	offsetY = 0
	
	layerNum = 1
	isOpening = false
	
	bCursor = {}
	bCursor.index = 0
	bCursor.paintingTile = 1
	bCursor.paintingObj = 1
	bCursor.currentModePaint = bCursor.paintingTile
	
	editingMode = 1
	editingModeTbl = {"wallobj", "browsers"}
	
	things = {}
	things[0] = "NADA"
	things[1] = "BAGHEAD"
	things[2] = "BIRDSOLDIER"
	things[3] = "FURSUITER"
	things[4] = "NUMNUMZ (NI)"
	things[5] = "BOSSTOI"
	things[6] = "BOSSFATT"
	things[7] = "BOSSFROGOUT"
	things[8] = "BOSSBIGBIRD"
	things[9] = "BOSSTREEMIGHT"
	things[10] = "BOSSABBYO"
	things[11] = "SUBMACGUN"
	things[12] = "SUBMACAMMO"
	things[13] = "CHAINGUN"
	things[14] = "CHAINGUNAMMO"
	things[15] = "RCKTLAUNCHER"
	things[16] = "ROCKETAMMO"
	things[17] = "MAPLERIFLE"
	things[18] = "MAPLEAMMO"
	things[19] = "SMALLHEALTH"
	things[20] = "LARGEHEALTH"
	things[21] = "ONEUPORB"
	things[22] = "SCOREFSLICE"
	things[23] = "SCORETHORTONS"
	things[24] = "SCOREPOUTINE"
	things[25] = "SCOREMRSUBSUB"
	things[26] = "PLAYEREST"
	things[27] = "PLAYERSUD"
	things[28] = "PLAYEROUEST"
	things[29] = "PLAYERNORD"
	things[30] = "EXITNORMAL"
	things[31] = "EXITSECRET"
	things[32] = "DOORNORMHZ"
	things[33] = "DOORNORMVT"
	things[34] = "DOORLCKBHZ"
	things[35] = "DOORLCKBVT"
	things[36] = "DOORLCKRHZ"
	things[37] = "DOORLCKRVT"
	things[38] = "KEYBLUE"
	things[39] = "KEYRED"
	-- Props after this.
	
	currentObj = {}
	currentTile = {}
	
	currentThing = {}
	currentThing.tnum = 0		-- the number for reference
	currentThing.title = ""
	currentThing.posx = 0		-- position on grid (X)
	currentThing.posy = 0		-- position on grid (Y)
	currentThing.spr = nil
	
	tileArray = {}
	tileStruct = {}
	tileStruct.tnum = 0		-- the tile number representing
	tileStruct.posx = 0		-- position on grid (X)
	tileStruct.posy = 0		-- position on grid (Y)
	tileStruct.spr = nil
	
	objArray = {}
	objStruct = {}
	objStruct.tnum = 0		-- the thing number
	objStruct.posx = 0		-- position on Grid (X)
	objStruct.posy = 0		-- position on Grid (Y)
	objStruct.spr = nil
	runModeFlag = false
	
	selectedTile = 0
	selectedObj = 0
	
	mapNumber = 1
	
	savingTimer = 100
	openingTimer = 100
	
	isInHelp = false
	helpPage = 1
	
	for k = 1, sizeOfMapY do
		for l = 1, sizeOfMapX do
			tileStruct.tnum = 1
			tileStruct.posx = l
			tileStruct.posy = k
			table.insert(tileArray, tileStruct)
			tileStruct = {}
		end
	end
	
	for m=1, sizeOfMapY do
		for n=1, sizeOfMapX do
			objStruct.tnum = 0
			objStruct.posx = n
			objStruct.posy = m
			table.insert(objArray, objStruct)
			objStruct = {}
		end
	end
end

function love.update(dt)
	if isReading == false and isWriting == false and isReadyToEdit == true then
		inputCheck()
		checkCurrentThing()
	end
	if dialogCooldown ~= 90 then
		dialogCooldown = dialogCooldown + 1
	end
	if inputCooldown ~= 10 then
		inputCooldown = inputCooldown + 1
	end
	if savingTimer ~= 100 then
		savingTimer = savingTimer + 1
	end
	if openingTimer ~= 100 then
		openingTimer = openingTimer + 1
	end
end

function checkCurrentThing()
	if layerNum == 1 then
		currentTile = checkCurrentTile()
		currentThing.tnum = currentTile.tnum
		currentThing.x = currentTile.posx
		currentThing.y = currentTile.posy
		currentThing.spr = tiles[currentThing.tnum]
		currentTile = {}
	end
	if layerNum == 2 then
		currentObj = checkCurrentObj()
		currentThing.tnum = currentObj.tnum
		currentThing.title = things[currentThing.tnum]
		currentThing.spr = getSpriteFromNum(currentThing.tnum)
		currentThing.x = currentObj.posx
		currentThing.y = currentObj.posy
		currentObj = {}
	end
end

function getSpriteFromNum(num)
	if num == 1 then
		return sprites[1]
	elseif num == 2 then
		return sprites[2]
	elseif num == 3 then
		return sprites[3]
	elseif num == 5 then
		return sprites[4]
	elseif num == 6 then
		return sprites[5]
	elseif num == 7 then
		return sprites[6]
	elseif num == 11 then
		return sprites[7]
	elseif num == 12 then
		return sprites[8]
	elseif num == 13 then
		return sprites[9]
	elseif num == 14 then
		return sprites[10]
	elseif num == 15 then
		return sprites[11]
	elseif num == 16 then
		return sprites[12]
	elseif num == 17 then
		return sprites[13]
	elseif num == 18 then
		return sprites[14]
	elseif num == 19 then
		return sprites[15]
	elseif num == 20 then
		return sprites[16]
	elseif num == 21 then
		return sprites[17]
	elseif num == 22 then
		return sprites[18]
	elseif num == 23 then
		return sprites[19]
	elseif num == 24 then
		return sprites[20]
	elseif num == 25 then
		return sprites[21]
	elseif num >= 26 and num <= 29 then
		return sprites[22]
	elseif num == 30 then
		return sprites[23]
	elseif num == 31 then
		return sprites[24]
	elseif num == 32 then
		return sprites[25]
	elseif num == 33 then
		return sprites[26]
	elseif num == 34 then
		return sprites[27]
	elseif num == 35 then
		return sprites[28]
	elseif num == 36 then
		return sprites[29]
	elseif num == 37 then
		return sprites[30]
	elseif num == 38 then
		return sprites[32]
	elseif num == 39 then
		return sprites[31]
	else
		return nil
	end
end

function checkCurrentTile()
	for i, v in ipairs(tileArray) do
		if tileArray[i].posx == cursor.x and tileArray[i].posy == cursor.y then
			return tileArray[i]
		end
	end
end

function checkCurrentObj()
	for j, v in ipairs(objArray) do
		if objArray[j].posx == cursor.x and objArray[j].posy == cursor.y then
			return objArray[j]
		end
	end
end

function inputCheck()
	if inputCooldown >= 10 then
		if love.keyboard.isDown("f1") then
			isInHelp = true
			inputCooldown = 0
		end
		if ((love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")) and
			love.keyboard.isDown("q")) then
			os.exit(0)
		end
		if love.keyboard.isDown(" ") and isInHelp == true then
			helpPage = helpPage + 1
			if helpPage > 1 then
				helpPage = 1
				isInHelp = false
			end
			inputCooldown = 0
		end
		if love.keyboard.isDown("escape") and isInHelp == true then
			isInHelp = false
			inputCooldown = 0
		end
		if isInHelp == false then
			if love.keyboard.isDown("b") then
				if editingMode == 1 then
					bCursor.x = 1
					bCursor.y = 1
					editingMode = 2
				elseif editingMode == 2 then
					bCursor.index = 0
					editingMode = 1
				end
				inputCooldown = 0
			end
			if love.keyboard.isDown("m") then
				if editingMode == 1 then
					editingMode = 3
				elseif editingmode == 3 then
					editingMode = 1
				end
			end
			if editingMode == 1 then
				if love.keyboard.isDown("up") then
					cursor.y = cursor.y - 1
					if shifting == false then
						inputCooldown = 0
					end
					if cursor.y < 1 then
						cursor.y = 1
					end
				end
				if love.keyboard.isDown("down") then
					cursor.y = cursor.y + 1
					if shifting == false then
						inputCooldown = 0
					end
					if cursor.y > sizeOfMapY then
						cursor.y = sizeOfMapY
					end
					inputCooldown = 0
				end
				if love.keyboard.isDown("left") then
					cursor.x = cursor.x - 1
					if shifting == false then
						inputCooldown = 0
					end
					if cursor.x < 1 then
						cursor.x = 1
					end
					inputCooldown = 0
				end
				if love.keyboard.isDown("l") then
					if layerNum == 1 then
						layerNum = 2
						bCursor.currentModePaint = bCursor.paintingObj
					else
						layerNum = 1
						bCursor.currentModePaint = bCursor.paintingTile
					end
					inputCooldown = 0
				end
				if love.keyboard.isDown("d") then
					changeTileOrObject(0)
					-- inputCooldown = 0
				end

				if love.keyboard.isDown("f") then
					changeTileOrObject(bCursor.currentModePaint)
					inputCooldown = 0
				end	
				if love.keyboard.isDown("h") then
					hollowOutTiles()
					inputCooldown = 0
				end
				if love.keyboard.isDown("right") then
					cursor.x = cursor.x + 1
					if shifting == false then
						inputCooldown = 0
					end
					if cursor.x > sizeOfMapX then
						cursor.x = sizeOfMapX
					end
				end
				if love.keyboard.isDown(" ") and dialogCooldown >= 90 then
					cursor.isInDialog = not cursor.isInDialog
					dialogCooldown = 0
					inputCooldown = 0
				end
				if (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")) and
					love.keyboard.isDown("s") and isSaving == false then
					savingTimer = 0
					saveCurrentMap()
					dialogCooldown = 0
					inputCooldown = 0
				end
				if (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")) and 
					love.keyboard.isDown("o") and isOpening == false then
					openingTimer = 0
					openCurrentMap()
					dialogCooldown = 0
					inputCooldown = 0
				end
				if love.keyboard.isDown("r") then
					shifting = not shifting
					runModeFlag = not runModeFlag
					inputCooldown = 0
				end
			end
			if editingMode == 2 then
				local movx = 0
				local movy = 0
				if layerNum == 1 then
					movy = 29
					movx = 1
				end
				if layerNum == 2 then
					movy = 1
					movx = 17
				end
				if love.keyboard.isDown("up") then
					bCursor.index = bCursor.index - movy
					adjustBrowserCursor()
					inputCooldown = 0
				end
				if love.keyboard.isDown("down") then
					bCursor.index = bCursor.index + movy
					adjustBrowserCursor()
					inputCooldown = 0
				end
				if love.keyboard.isDown("left") then
					bCursor.index = bCursor.index - movx
					adjustBrowserCursor()
					inputCooldown = 0
				end
				if love.keyboard.isDown("right") then
					bCursor.index = bCursor.index + movx
					adjustBrowserCursor()
					inputCooldown = 0
				end
				if love.keyboard.isDown(" ") then
					local tmpbc = bCursor.index
					bCursor.index = 0
					if layerNum == 1 then
						bCursor.paintingTile = tmpbc
						bCursor.currentModePaint = tmpbc
					end
					if layerNum == 2 then
						bCursor.paintingObj = tmpbc
						bCursor.currentModePaint = tmpbc
						changeTileOrObject(tmpbc)
					end
					editingMode = 1
					inputCoolDown = 0
				end
				if love.keyboard.isDown("escape") then
					bCursor.index = 0
					editingMode = 1
				end
			end
			if editingMode == 3 then
				if love.keyboard.isDown("[") then
					mapNumber = mapNumber - 1
					if mapNumber < 1 then
						mapNumber = 1
					end
					inputCooldown = 0
				elseif love.keyboard.isDown("]") then
					mapNumber = mapNumber + 1
					if mapNumber > 60 then
						mapNumber = 60
					end
					inputCooldown = 0
				end
				if love.keyboard.isDown("return") or
					love.keyboard.isDown("escape") then
					editingMode = 1
				end
			end
		end
	end
end

function changeTileOrObject(too)
	if layerNum == 1 then
		changeTile(too)
	elseif layerNum == 2 then
		changeObject(too)
	end
end

function changeTile(o)
	for i, v in ipairs(tileArray) do
		if tileArray[i].posx == cursor.x and tileArray[i].posy == cursor.y then
			tileArray[i].tnum = o
		end
	end
end

function changeObject(o)
	for i, v in ipairs(objArray) do
		if objArray[i].posx == cursor.x and objArray[i].posy == cursor.y then
			objArray[i].tnum = o
		end
	end
end

function hollowOutTiles()
	for i, v in ipairs(tileArray) do
		if (tileArray[i].posx > 1 and tileArray[i].posy > 1) and
			(tileArray[i].posx < sizeOfMapX and tileArray[i].posy < sizeOfMapY) and
			tileArray[i].tnum ~= 0 then
			tileArray[i].tnum = 0
		end
	end
end

function openCurrentMap()
	if mapNumber >= 1 and mapNumber <= 60 then
		local omap = nil
		if mapNumber >= 1 and mapNumber <= 9 then
			omap = io.open("map0"..mapNumber..".lua", "r")
			if omap ~= null then
				local xin = 1
				local yin = 1
				local line = nil
				local mode = 1
				while true do
					line = omap:read("*l")
					if line == "-- Generated by PDomEdit. Map #: "..mapNumber then
						xin = 1
						yin = 1
					end
					if line == nil then break end
					if string.find(line, "map") ~= nil and mode < 3 then
						local tmpD = {}
						local tmpA = string.find(line, "{")
						local tmpB = string.find(line, "}")
						local tmpC = string.sub(line, tmpA, tmpB)
						for word in string.gmatch(tmpC, '%d+') do
							tmpD[xin] = tonumber(word)
							xin = xin + 1
						end
						xin = 1
						while xin <= sizeOfMapX do
							if mode == 1 then
								loadTilesFromMap(tmpD[xin], xin, yin)
							elseif mode == 2 then
								loadObjsFromMap(tmpD[xin], xin, yin)
							end
							xin = xin + 1
						end
						if xin > sizeOfMapX then
							xin = 1
							yin = yin + 1
						end
						if yin > sizeOfMapY then
							xin = 1
							yin = 1
							mode = mode + 1
							tmpD = {}
						end
					end
				end
				omap:close()
			end
		end
		elseif mapNumber >= 10 and mapNumber <= 60 then
			omap = io.open("map"..mapNumber..".lua", "r")
			if omap ~= null then
				local xin = 1
				local yin = 1
				local line = nil
				local mode = 1
				while true do
					line = omap:read("*l")
					if line == "-- Generated by PDomEdit. Map #: "..mapNumber then
						xin = 1
						yin = 1
					end
					if line == nil then break end
					if string.find(line, "map") ~= nil or string.find(line, "objmap") ~= nil and mode < 3 then
						local tmpD = {}
						local tmpA = string.find(line, "{")
						local tmpB = string.find(line, "}")
						local tmpC = string.sub(line, tmpA, tmpB)
						for word in string.gmatch(tmpC, '%d+') do
							tmpD[xin] = tonumber(word)
							xin = xin + 1
						end
						xin = 1
						while xin <= sizeOfMapX do
							if mode == 1 then
								loadTilesFromMap(tmpD[xin], xin, yin)
							elseif mode == 2 then
								loadObjsFromMap(tmpD[xin], xin, yin)
							end
							xin = xin + 1
						end
						if xin > sizeOfMapX then
							xin = 1
							yin = yin + 1
						end
						if yin > sizeOfMapY then
							xin = 1
							yin = 1
							mode = mode + 1
							tmpD = {}
						end
					end
				end
			omap:close()
		end
	end
end

function loadTilesFromMap(o, x ,y)
	for i, v in ipairs(tileArray) do
		if tileArray[i].posx == x and tileArray[i].posy == y then
			tileArray[i].tnum = o
		end
	end
end

function loadObjsFromMap(o, x ,y)
	for i, v in ipairs(objArray) do
		if objArray[i].posx == x and objArray[i].posy == y then
			objArray[i].tnum = o
		end
	end
end

function saveCurrentMap()
	if mapNumber >= 1 and mapNumber <= 60 then
		local fmap = nil
		if mapNumber >= 1 and mapNumber <= 9 then
			local bak = io.open("map0"..mapNumber..".lua", "r")
			if bak ~= null then
				local bakout = io.open("map0"..mapNumber..".lua.bak", "w")
				bakout:write(bak:read("*all"))
				bakout:close()
				bak:close()
			end
			fmap = io.open("map0"..mapNumber..".lua", "w")
		else
			local bak = io.open("map"..mapNumber..".lua", "r")
			if bak ~= null then
				local bakout = assert(io.open("map"..mapNumber..".lua.bak", "w"))
				bakout:write(bak:read("*all"))
				bakout:close()
				bak:close()
			end
			fmap = assert(io.open("map"..mapNumber..".lua", "w"))
		end
		fmap:write("-- Generated by PDomEdit. Map #: "..mapNumber.."\n")
		local amountH = 1
		local amountX = 1
		local amountY = 1
		local prevAmountY = 0
		local beginningWrote = false
		for i, v in ipairs(tileArray) do
			if amountY > prevAmountY and beginningWrote == false then
				fmap:write("map["..amountY.."] = {")
				beginningWrote = true
			end
			if amountX == tileArray[i].posx and amountY == tileArray[i].posy then
				fmap:write(""..tileArray[i].tnum)
			end
			if amountX < sizeOfMapX then
				fmap:write(", ")
			end
			amountX = amountX + 1
			if amountX > sizeOfMapX then
				fmap:write("}\n")
				amountX = 1
				prevAmountY = amountY
				beginningWrote = false
				amountY = amountY + 1
			end
		end
		amountH = 1
		amountX = 1
		amountY = 1
		prevAmountY = 0
		beginningWrote = false
		for j, v in ipairs(objArray) do
			if amountY > prevAmountY and beginningWrote == false then
				fmap:write("objmap["..amountY.."] = {")
				beginningWrote = true
			end
			if amountX == objArray[j].posx and amountY == objArray[j].posy then
				fmap:write(""..objArray[j].tnum)
			end
			if amountX < sizeOfMapX then
				fmap:write(", ")
			end
			amountX = amountX + 1
			if amountX > sizeOfMapX then
				fmap:write("}\n")
				amountX = 1
				prevAmountY = amountY
				beginningWrote = false
				amountY = amountY + 1
			end
		end
		io.close(fmap)
	end
end

function adjustBrowserCursor()
	if layerNum == 1 then
		if bCursor.index > 172 then
			bCursor.index = 0
		end
		if bCursor.index <= -1 then
			bCursor.index = 172
		end
	end
	if layerNum == 2 then
		if bCursor.index > 39 then
			bCursor.index = 0
		end
		if bCursor.index <= -1 then
			bCursor.index = 39	-- for now
		end
	end
end

function love.draw()
	if editingMode == 1 or editingMode == 2 or editingMode ==3 and isInHelp == false then
		drawBoard()
		drawCursor()
		drawStatusBar()
		if editingMode == 2 then
			if layerNum == 2 then
				drawObjectBrowser()
			else
				drawWallBrowser()
			end
		end
		if editingMode == 3 then
			drawLevelChangeMsg()
			drawCurrentLevelNum()
		end
		if savingTimer < 100 then
			drawSavingDialog()
		end
		if openingTimer < 100 then
			drawOpeningDialog()
		end
	end
	if isInHelp == true then
		drawHelpScreen()
	end
end

function drawHelpScreen()
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle("fill", 0, 0, 1280, 800)
	love.graphics.setColor(255, 255, 255, 255)
	if helpPage == 1 then
		love.graphics.printf("The Controls:\n\nArrow Keys = Move and Browse\nL -> Layer Toggle\nM -> Map Number Selection\nCtrl+S - > Back up map and Save\nCtrl+O -> open current map number\nD -> Eraser\nF -> Pencil Tool\nH-> Hollow Out Level to border\nB -> Open Tile or Object BrowserCtrl+Q -> Quit Program (Doesn't save changes so be careful)", 320, 32, 800, "left")
		love.graphics.printf("The Layers:\n\nLayer No 1 -> Tiles(Walls)\nThis is where solid walls go\n\nLayer No 2 - > Objects(Things)\nThis is where things such as the player and pickups go.", 320, 256, 800, "left")
		love.graphics.printf("There is an experimental implemented feature called Run Mode which allows you to draw faster. It can disappear at ANY TIME! To toggle press R.", 320, 512, 900, "left")
	end
end

function drawSavingDialog()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 384, 256, 512, 384)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Saving map #: "..mapNumber, 460, 448, 400, "center")
end

function drawOpeningDialog()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 384, 256, 512, 384)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Opening map #: "..mapNumber, 460, 448, 400, "center")
end

function drawLevelChangeMsg()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 384, 256, 512, 384)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Press [ or ] to change the mapno. Press Escape to leave!", 460, 448, 400, "center")
end

function drawCurrentLevelNum()
	love.graphics.printf("You are working with level #: "..mapNumber, 460, 500, 400, "center")
end

function drawBoard()
	offsetX = 0
	offsetY = 0
	for i, v in ipairs(tileArray) do
		if tileArray[i].tnum > 0 then
			local tileTmpNum = tileArray[i].tnum
			love.graphics.draw(tiles[tileTmpNum], (tileArray[i].posx * sizeOfObj) - offsetX, (tileArray[i].posy * sizeOfObj) - offsetY, 0, 0.25, 0.25, 0, 0)
		end
	end
	for j, w in ipairs(objArray) do
		if objArray[j].tnum > 0 then
			local objTempNum = objArray[j].tnum
			local objSprite = getSpriteFromNum(objTempNum)
			if objSprite ~= nil then
				love.graphics.draw(objSprite, (objArray[j].posx * sizeOfObj) - offsetX, (objArray[j].posy * sizeOfObj) - offsetY, 0, 0.25, 0.25, 0, 0)
			end
		end
	end
end

function drawCursor()
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.rectangle("line", math.floor(((cursor.x) * sizeOfObj)), math.floor(((cursor.y) * sizeOfObj)), sizeOfObj, sizeOfObj)
end

function drawStatusBar()
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.rectangle("fill",  0, 700, 1280, 100)
	love.graphics.setColor(255, 255, 255, 255)
	drawMessagesOnSBar()
end

function drawMessagesOnSBar()
	local layerName = ""
	if layerNum == 1 then
		layerName = "Tilewall Layer"
	elseif layerNum == 2 then
		layerName = "Objects Layer"
	end
	love.graphics.printf("PDomEdit v.0.2 by Kraigose Studios", 10, 705, 400, "left") 
	love.graphics.printf("Layer: "..layerName, 10, 725, 400, "left")
	love.graphics.printf("Thingnum: "..currentThing.tnum, 10, 740, 150, "left")
	love.graphics.printf("Info:: X: "..currentThing.x.." Y: "..currentThing.y, 10, 755, 250, "left")
	if layerNum == 2 then
		love.graphics.printf("Obj. Name: "..currentThing.title, 10, 770, 400, "left")
	end
	if runModeFlag == true then
		love.graphics.printf("Run Mode ON. No whining.", 840, 770, 400, "right")
	end
	drawSelectedTileAndObj()
end

function drawSelectedTileAndObj()
	if bCursor.paintingTile > 0 then
		love.graphics.draw(tiles[bCursor.paintingTile], 600, 730, 0, 0.75, 0.75, 0, 0)
	end
	love.graphics.printf("=Current Tile=", 512, 780, 256, "center")
	if bCursor.paintingObj > 0 then
		love.graphics.draw(getSpriteFromNum(bCursor.paintingObj), 800, 730, 0, 0.75, 0.75, 0, 0)
	end
	love.graphics.printf("=Current Object=", 700, 780, 256, "center")
end

function drawWallBrowser()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 128, 32, 1024, 512)
	love.graphics.setColor(255, 0, 255, 255)
	love.graphics.rectangle("line", 128, 32, 1024, 512)
	love.graphics.setColor(255, 255, 255, 255)
	local drawListXPos = 192
	local drawListYPos = 32
	local drawCursorYPos = 0
	local maxAmtOfItems = 27
	local amountOfItemsDrawn = 0
	for k=0, 172,1 do
		if tiles[k] ~= nil then
			if k == bCursor.index then
				love.graphics.setColor(255, 0, 255, 255)
			else
				love.graphics.setColor(255, 255, 255, 255)
			end
			if k >= 1 then
				love.graphics.draw(tiles[k], drawListXPos, drawListYPos, 0, 0.5, 0.5, 0, 0)
			end
			drawListXPos = drawListXPos + 32
			amountOfItemsDrawn = amountOfItemsDrawn + 1
			if amountOfItemsDrawn > maxAmtOfItems then
				if maxAmtOfItems == 27 then
					maxAmtOfItems = 28
				end
				amountOfItemsDrawn = 0
				drawListXPos = 160
				drawListYPos = drawListYPos + 32
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
	local textForWall = ""
	local wallNum = bCursor.index
	if bCursor.index == 0 then
		textForWall = "No Wall - NULL"
	else
		textForWall = "Wall # "..wallNum
	end
	love.graphics.printf(textForWall, 512, 512, 512, "center")
end

function drawObjectBrowser()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", 128, 32, 1024, 512)
	love.graphics.setColor(255, 0, 255, 255)
	love.graphics.rectangle("line", 128, 32, 1024, 512)
	love.graphics.setColor(255, 255, 255, 255)
	local drawListXPos = 160
	local drawListYPos = 32
	local drawSpriteX = 720
	local drawSpriteY = 720
	local drawCursorYPos = 0
	local maxAmtOfItems = 16
	local amountOfItemsDrawn = 0
	for k=0, 112,1 do
		if k == bCursor.index then
			love.graphics.setColor(255, 0, 255, 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		if things[k] ~= nil then
			love.graphics.printf(things[k], drawListXPos, drawListYPos, 300, "left")
			drawListYPos = drawListYPos + 16
			amountOfItemsDrawn = amountOfItemsDrawn + 1
			if amountOfItemsDrawn > maxAmtOfItems then
				amountOfItemsDrawn = 0
				drawListYPos = 32
				drawListXPos = drawListXPos + 160
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end