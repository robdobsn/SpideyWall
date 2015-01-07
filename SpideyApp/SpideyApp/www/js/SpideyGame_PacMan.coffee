class SpideyGame_PacMan extends SpideyGame
	constructor: (@spideyApp, @spideyWall, @spideyAppUI) ->
		super("PacMan", "pacman.svg")
		@me = new PacManSprite("me", 39, "green", @spideyWall)
		@baddies = [ new PacManSprite("bad1", 66, "red", @spideyWall), new PacManSprite("bad2", 75, "red", @spideyWall) ]
		return

	go: () ->
		# Called from main UI when game started
		@spideyAppUI.addButton("red", @exitClick, "exit", "exit", "exit", "appbar.cancel.svg", 50, 50, "#gamebuttons", 1)
		@spideyAppUI.showGamePad(200,100)
		@testStart()
		return

	exitClick: =>
		@testEnd()
		@spideyApp.exitGame()

	showSprites: ->
		@spideyWall.preShowAll()
		# for actor in @baddies
		# 	actor.show()
		@me.show()
		@spideyWall.showAll()
		return

	step: =>
		@me.moveMe()
		for actor in @baddies
			actor.moveBaddie(@me)
		@showSprites()
		return

	mouseover: (dirn) ->
		#console.log @dirn
		if dirn is "forward" or dirn is "back"
			@me.curDirection.move = dirn
			@me.curDirection.turn = "none"
		else if dirn is "left" or dirn is "right"
			@me.curDirection.turn = dirn
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

