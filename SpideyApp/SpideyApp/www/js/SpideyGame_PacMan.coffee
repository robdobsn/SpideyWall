# Spidey game PacMan

class SpideyGame_PacMan extends SpideyGame

	constructor: (@spideyApp, @spideyWall, @spideyAppUI) ->
		super("PacMan", "pacman.svg")
		@pacmanSprite = new PacManSprite("pacman", 43, 0, 0, "#ffee00", true, 0, @spideyWall, @spideyAppUI)
		@ghostSprites = [ 
			new PacManSprite("blinky", 73, 0, 0, "#ff0000", false, 0, @spideyWall, @spideyAppUI) 
			new PacManSprite("pinky", 79, 5, 0, "#ffc0cb", false, 1, @spideyWall, @spideyAppUI) 
			new PacManSprite("inky", 70, 30, 0, "#00bfff", false, 2, @spideyWall, @spideyAppUI) 
			new PacManSprite("clyde", 40, @spideyWall.getNumPoints()/3, 20, "#ff8000", false, 3, @spideyWall, @spideyAppUI)
		]
		@pillPositions = [
			{ type: 1, pointIdx: 720, nodeIdx: 57, linkIdx: 2, linkStep: 5 }
			{ type: 1, pointIdx: 268, nodeIdx: 15, linkIdx: 2, linkStep: 6 }
			{ type: 1, pointIdx: 372, nodeIdx: 23, linkIdx: 0, linkStep: 2 }
			{ type: 1, pointIdx: 624, nodeIdx: 47, linkIdx: 1, linkStep: 0 }
		]
		# Location of the ghost house - node the ghosts emerge from
		@ghostHouseNode = 1
		# Dots to be eaten
		@generateGameDots()
		@pacManDots = new PacManDots(@gameDots, 5, @spideyWall, @spideyAppUI)
		@spideyAppUI.setResizeCallback(@resizeCallback)
		return

	go: () ->
		@spideyAppUI.showGameUI(true)
		@spideyAppUI.setDirectionCallback(@directionCallback)
		for ghost in @ghostSprites
			ghost.showInitially()
		@pacmanSprite.showInitially()
		@pacManDots.showInitially()
		# @testStart()
		@gameTimer = setInterval(@step, 50)

		$("#spriteOverlay").on "mousemove", @mouseMoveTest
		$("#spriteOverlay").on "mousedown", @mouseDownTest
		return

	generateGameDots: () ->
		# Generate array of game dots
		tmpPillPoints = []
		for pillPt, pillIdx in @pillPositions
			tmpPillPoints.push(pillPt.pointIdx)
		@gameDots = []
		for point, pointIdx in @spideyWall.getPoints()
			dotType = 0
			pillIdx = -1
			if pointIdx in tmpPillPoints
				pillIdx = tmpPillPoints.indexOf(pointIdx)
				dotType = @pillPositions[pillIdx]
			@gameDots.push
				dotType: dotType
				pillIdx: pillIdx
		return

	resizeCallback: () =>
		for ghost in @ghostSprites
			ghost.resizeUI()
		@pacmanSprite.resizeUI()
		@pacManDots.resizeUI()
		return

	updateSprites: ->
		for ghost in @ghostSprites
			ghost.updateUI()
		@pacmanSprite.updateUI()
		return

	step: =>
		@pacmanSprite.movePacman()
		for ghost in @ghostSprites
			ghost.moveGhost(@pacmanSprite, @ghostSprites[0])
		@updateSprites()
		return

	directionCallback: (param) =>
		@changeDirection(param)
		return

	mouseover: (dirn) ->
		@changeDirection(dirn)
		return

	changeDirection: (dirn) ->
		#console.log @dirn
		@pacmanSprite.setDirection(dirn)
		return

	getDebugInfo: () ->
		return "N " + @pacmanSprite.curLocation.node + " L " + @pacmanSprite.curLocation.linkIdx + " S " + @pacmanSprite.curLocation.linkStep

	stepTest: () =>
		# @execSpideyCmd("http://macallan:5078/rawcmd/000100010100050605000080")
		# cmdStr = "000802" + @zeropad(@d2h(@testCurLed), 4) + "0001" + "000080"
		# @execSpideyCmd("http://macallan:5078/rawcmd/0001000101" + cmdStr)
		@spideyAppUI.preShowAll()
		@spideyAppUI.sendLedCmd(@testCurLed, "red")
		@spideyAppUI.showAll()
		@testCurLed += 1
		return

	testStart: () =>
		@testCurLed = 0
		@tmr = setInterval(@stepTest, 50)
		# @mediaPlayHelper.play("ok")
				# @mediaPlayHelper.play("fail")
		return

	testEnd: () ->
		clearInterval(@tmr)
		return

	mouseMoveTest: (event) =>
		# console.log event.pageX
		# Find nearest node
		offs = $("#spriteOverlay").offset()
		spriteXY =
			x: event.pageX - offs.left
			y: event.pageY - offs.top
		xySpidey = @spideyAppUI.getSpideyWallCoords(spriteXY)
		nodIdx = @spideyWall.getNodeNearXY(xySpidey.x, xySpidey.y)
		pointIdx = @spideyWall.getPointNearXY(xySpidey.x, xySpidey.y)
		point = @spideyWall.getPoints()[pointIdx]
		console.log "X " + xySpidey.x + " Y " + xySpidey.y + " near nodeIdx " + nodIdx + " ptIdx " + pointIdx + " ptNodIdx " + point.nodeIdx + " lnkIdx " + point.linkIdx + " linkStep " + point.linkStep
		return

	mouseDownTest: (event) =>
		# console.log event.pageX
		# Find nearest node
		offs = $("#spriteOverlay").offset()
		spriteXY =
			x: event.pageX - offs.left
			y: event.pageY - offs.top
		xySpidey = @spideyAppUI.getSpideyWallCoords(spriteXY)
		nodIdx = @spideyWall.getNodeNearXY(xySpidey.x, xySpidey.y)
		console.log "X " + xySpidey.x + " Y " + xySpidey.y + " idx " + nodIdx
		@pacmanSprite.moveToNode(nodIdx)
		@pacmanSprite.updateUI()
		numLinks = @spideyWall.getNumLinks(nodIdx)
		for lidx in [0...numLinks]
			console.log @spideyWall.getLinkAngle(nodIdx, lidx, 1)
		return

	exitClick: =>
		# @testEnd()
		clearInterval(@gameTimer)
		@spideyApp.exitGame()
		return

