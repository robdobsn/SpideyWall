class SpideyAppUI
	constructor: () ->
		@mediaPlayHelper = new MediaPlayHelper(
			{
				click: "assets/click.mp3",
				ok: "assets/blip.mp3",
				fail: "assets/fail.mp3"
			})
		@curTileIdx = 0

	init: ->
		# Basic body for DOM
		$("body").prepend """
			<div id="sqWrapper">
				<div id="gamesAvailable">
				</div>
				<div id="gamebuttons">
				</div>
			</div>
			"""
		# Handler for orientation change
		$(window).on 'orientationchange', =>
		  @rebuildUI()
		# And resize event
		$(window).on 'resize', =>
		  @rebuildUI()

		@buttonColours = [ "red", "green", "blue", "brown" ]
		@nextButtonColour = 0

		@gamesAvail = {}

	rebuildUI: =>
		return

	showGamesAvailable: (showIt) ->
		if showIt
			$("#gamesAvailable").show()
		else
			$("#gamesAvailable").hide()

	showGameUI: (showIt) ->
		if showIt
			$("#gamebuttons").show()
		else
			$("#gamebuttons").hide()

	addGame: (game, gameClick) ->
		@addButton(@getButtonColour(), @selGame, game.gameName, game.gameName, game.gameName, game.gameIcon, 100, 100, "#gamesAvailable", 2)
		@gamesAvail[game.gameName] =
			game: game
			gameClick: gameClick
		return

	selGame: (param) =>
		if param of @gamesAvail
			@gamesAvail[param].gameClick(@gamesAvail[param].game)

	getButtonColour: ->
		butCol = @buttonColours[@nextButtonColour]
		@nextButtonColour += 1
		if @nextButtonColour >= @buttonColours.length
			@nextButtonColour = 0
		return butCol

	addButton: (colour, clickFn, clickParam, name, text, iconname, x, y, parentselector, size) ->
		tb = new TileBasics(colour, size, size, clickFn, clickParam, name, "all", parentselector, "gamebutton", iconname, true, @mediaPlayHelper)
		tb.setTierGroupIds(0,0)
		button = new Tile(tb)
		button.setTileIndex(@curTileIdx)
		@curTileIdx += 1
		button.addToDoc()
		button.reposition(x,y,size*100,size*100,1)
		button.setText(text)
		return

	showGamePad: (tlx, tly) -> 
		@addButton("red", @arrowClick, "up", "up", "UP", "appbar.arrow.up.svg", tlx+200, tly, "#gamebuttons", 2)
		@addButton("yellow", @arrowClick, "left", "left", "LEFT", "appbar.arrow.left.svg", tlx, tly+200, "#gamebuttons", 2)
		@addButton("green", @arrowClick, "down", "down", "DOWN", "appbar.arrow.down.svg", tlx+200, tly+400, "#gamebuttons", 2)
		@addButton("blue", @arrowClick, "right", "right", "RIGHT", "appbar.arrow.right.svg", tlx+400, tly+200, "#gamebuttons", 2)
		return

