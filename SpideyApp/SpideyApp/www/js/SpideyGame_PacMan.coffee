class SpideyGame_PacMan extends SpideyGame
	constructor: (@spideyApp, @spideyWall, @spideyAppUI) ->
		super("PacMan", "pacman.svg")
		@me = new PacManSprite("me", 39, "green", @spideyWall)
		@baddies = [ new PacManSprite("bad1", 66, "red", @spideyWall), new PacManSprite("bad2", 75, "red", @spideyWall) ]
		return

	go: () ->
		# Called from main UI when game started
		# @spideyAppUI.addButton("red", @exitClick, "exit", "exit", "exit", "appbar.cancel.svg", 50, 50, "#gamebuttons", 100)
		@spideyAppUI.showGamePad(200,100, @directionCallback, true)
		# @testStart()
		@gameTimer = setInterval(@step, 100)
		return

	exitClick: =>
		# @testEnd()
		clearInterval(@gameTimer)
		@spideyApp.exitGame()

	showSprites: ->
		@spideyWall.preShowAll()
		for actor in @baddies
			actor.show()
		@me.show()
		@spideyWall.showAll()
		return

	step: =>
		@me.moveMe()
		for actor in @baddies
			actor.moveBaddie(@me)
		@showSprites()
		return

	directionCallback: (param) =>
		@changeDirection(param)

	mouseover: (dirn) ->
		@changeDirection(dirn)

	changeDirection: (dirn) ->
		#console.log @dirn
		@me.setDirection(dirn)
		return

	getDebugInfo: () ->
		return "N " + @me.curLocation.node + " L " + @me.curLocation.linkIdx + " S " + @me.curLocation.linkStep

	stepTest: () =>
		# @execSpideyCmd("http://macallan:5078/rawcmd/000100010100050605000080")
		# cmdStr = "000802" + @zeropad(@d2h(@testCurLed), 4) + "0001" + "000080"
		# @execSpideyCmd("http://macallan:5078/rawcmd/0001000101" + cmdStr)
		@spideyWall.preShowAll()
		@spideyWall.sendLedCmd(@testCurLed, "red")
		@spideyWall.showAll()
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

