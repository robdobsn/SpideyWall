# Spidey game PacMan

class SpideyGame_PacMan extends SpideyGame

	constructor: (@spideyApp, @spideyWall, @spideyAppUI) ->
		super("PacMan", "pacman.svg")
		# Location of the ghost house - node the ghosts emerge from
		@ghostHouseNode = 1
		@initGame()
		@gameRunning = false
		@lastMouseMoveTime = null
		return

	initGame: () ->
		# Init
		@pacmanSprite = new PacManSprite("pacman", 43, 0, 0, "#ffee00", true, 0, @ghostHouseNode, @spideyWall, @spideyAppUI)
		numDots = @spideyWall.getNumPoints()
		@ghostSprites = [ 
			new PacManSprite("blinky", 73, 0, 0, "#ff0000", false, 0, @ghostHouseNode, @spideyWall, @spideyAppUI) 
			new PacManSprite("pinky", 79, numDots/30, 0, "#ffc0cb", false, 1, @ghostHouseNode, @spideyWall, @spideyAppUI) 
			new PacManSprite("inky", 70, numDots/10, 0, "#00bfff", false, 2, @ghostHouseNode, @spideyWall, @spideyAppUI) 
			new PacManSprite("clyde", 40, numDots/3, 20, "#ff8000", false, 3, @ghostHouseNode, @spideyWall, @spideyAppUI)
		]
		@pillPositions = [
			{ type: 1, pointIdx: 720, nodeIdx: 57, linkIdx: 2, linkStep: 5 }
			{ type: 1, pointIdx: 268, nodeIdx: 15, linkIdx: 2, linkStep: 6 }
			{ type: 1, pointIdx: 372, nodeIdx: 23, linkIdx: 0, linkStep: 2 }
			{ type: 1, pointIdx: 624, nodeIdx: 47, linkIdx: 1, linkStep: 0 }
		]
		# Dots to be eaten
		@pacManDots = new PacManDots(@pillPositions, 5, 1, @spideyWall, @spideyAppUI)
		@spideyAppUI.setResizeCallback(@resizeCallback)
		@gameMode = 'scatter'
		@gameCounter = 0
		@scatterOnTime = 20
		@scatterOffTime = 50
		@frightenedInterval = 200
		@ghostsEatenScore = 0
		@initGhostEatScore = 100
		@nextGhostEatScore = @initGhostEatScore
		@scoreForDot = 10
		return

	go: (restart) ->
		if restart
			@initGame()
		@spideyAppUI.showGameUI(true)
		@spideyAppUI.setDirectionCallback(@directionCallback)
		for ghost in @ghostSprites
			ghost.showInitially()
		@pacmanSprite.showInitially()
		@pacManDots.showInitially()
		@gameTimer = setInterval(@step, 100)

		# Events
		$("#spriteOverlay").on "mousemove", @mouseMove
		$("#spriteOverlay").on "mousedown", @mouseDown
		$("body").on "touchstart", @touchStart
		$("body").on "touchmove", @touchMove
		$("body").on "touchend", @touchEnd
		@gameRunning = true

		return

	stop: () ->
		clearInterval(@gameTimer)
		@gameRunning = false
		return

	resizeCallback: () =>
		for ghost in @ghostSprites
			ghost.resizeUI()
		@pacmanSprite.resizeUI()
		@pacManDots.resizeUI()
		return

	updateSprites: ->
		for ghost in @ghostSprites
			ghost.updateUI(@gameMode, @gameCounter, @frightenedInterval)
		@pacmanSprite.updateUI(@gameMode)
		return

	step: =>
		inGameMode = @gameMode
		@pacmanSprite.movePacman()
		dotType = @pacManDots.beEaten(@pacmanSprite.getPositionPointIdx())
		if dotType isnt 0
			if @gameMode isnt 'frightened'
				@prevGameMode = @gameMode
				@nextGhostEatScore = @initGhostEatScore
			@gameMode = 'frightened'
			@gameCounter = 0
		for ghost in @ghostSprites
			collision = ghost.moveGhost(@gameMode, @pacmanSprite, @ghostSprites[0], @pacManDots.getDotsEaten())
			if collision
				if @gameMode is 'frightened'
					@ghostsEatenScore += @nextGhostEatScore
					@nextGhostEatScore = @nextGhostEatScore * 2
					ghost.sendBackHome(@pacManDots.getDotsEaten())
				else
					@stop()
					@spideyAppUI.showGameOver()
		@updateSprites()
		@updateScore()
		@gameCounter++
		if @gameMode is 'frightened'
			if @gameCounter > @frightenedInterval
				@gameMode = @prevGameMode
				@gameCounter = 0
		else
			if @gameMode is 'scatter'
				if @gameCounter > @scatterOnTime
					@gameMode = 'chase'
					@gameCounter = 0
			else
				if @gameCounter > @scatterOffTime
					@gameMode = 'scatter'
					@gameCounter = 0
		# if inGameMode isnt @gameMode
		# 	console.log "GameModeChanged now " + @gameMode
		return

	updateScore: () ->
		curScore = @pacManDots.getDotsEaten() * @scoreForDot
		curScore += @ghostsEatenScore
		$("#gameScore").text(curScore.toString())
		return

	directionCallback: (direction, distance) =>
		@changeDirection(direction)
		@spideyAppUI.updateJoystickBallUI(direction, distance)
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

	mouseMove: (event) =>
		# Check for swipes
		now = new Date()
		if @lastMouseMoveTime?
			if now - @lastMouseMoveTime > 100
				@swipeStart =
					x: event.pageX
					y: event.pageY
			else
				swipeEnd = 
					x: event.originalEvent.pageX
					y:  event.originalEvent.pageY
				if @swipeStart? and @spideyWall.dist(@swipeStart,swipeEnd) > 20
					@curReqdDirn = Math.atan2(swipeEnd.y - @swipeStart.y, swipeEnd.x - @swipeStart.x) * 180 / Math.PI
					@directionCallback(@curReqdDirn)
		@lastMouseMoveTime = now
		# @mouseMoveTest(event)
		return

	mouseDown: (event) =>
		# 
		return

	touchMove: (event) =>
		if @gameRunning
			event.preventDefault()
		return

	touchStart: (event) =>
		if @gameRunning
			event.preventDefault()
			if event.originalEvent.touches.length is 1
				@swipeStart = 
					x: event.originalEvent.touches[0].pageX
					y:  event.originalEvent.touches[0].pageY
		return

	touchEnd: (event) =>
		if @gameRunning
			if not @swipeStart?
				return
			swipeEnd = 
				x: event.originalEvent.pageX
				y:  event.originalEvent.pageY
			@curReqdDirn = Math.atan2(swipeEnd.y - @swipeStart.y, swipeEnd.x - @swipeStart.x) * 180 / Math.PI
			@directionCallback(@curReqdDirn)
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
		console.log "X " + Math.floor(xySpidey.x) + " Y " + Math.floor(xySpidey.y) + " near nodeIdx " + nodIdx + " ptIdx " + pointIdx + " ptNodIdx " + point.nodeIdx + " lnkIdx " + point.linkIdx + " linkStep " + point.linkStep
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
		@pacmanSprite.updateUI(@gameMode)
		numLinks = @spideyWall.getNumLinks(nodIdx)
		for lidx in [0...numLinks]
			console.log @spideyWall.getLinkAngle(nodIdx, lidx, 1)
		return

	exitClick: =>
		# @testEnd()
		clearInterval(@gameTimer)
		@spideyApp.exitGame()
		return

