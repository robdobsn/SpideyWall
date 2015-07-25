class SpideyAppUI

	constructor: () ->
		# For audio
		@mediaPlayHelper = new MediaPlayHelper(
			{
				click: "assets/click.mp3",
				ok: "assets/blip.mp3",
				fail: "assets/fail.mp3"
			})
		# Units of the voronoi pattern geometry - SpideyGeometry.js
		@origBackdropSize =
			width: 504
			height: 720
		# Handler for orientation change
		$(window).on 'orientationchange', =>
		  @rebuildUI()
		  return

		# And resize event
		$(window).on 'resize', =>
		  @rebuildUI()
		  return

		 return

	init: (@spideyWall, @restartCallback) ->
		# CSS for black background
		$("html").css
			background: "#000000"
			"-webkit-touch-callout": "none"
			"-webkit-user-select": "none"
			"-khtml-user-select": "none"
			"-moz-user-select": "none"
			"-ms-user-select": "none"
			"user-select": "none"
		# Basic body for DOM
		$("#gameArea").remove()
		$("body").prepend """
			<div id="gameArea" style="border:0;margin:0;padding:0">
				<div id="gameScore"
					style="position: absolute; left: 420px; border: 50px; color:white; z-index: 10; "></div>
		        <canvas id="spideyCanvas" 
		        	style="position: absolute; left: 0px; border: 0px; "></canvas>
				<div id="spriteOverlay" 
		        	style="position:absolute; ; left: 0px; border: 0px;">
				</div>
				<div id="gamebuttons" style="position:absolute;">
				</div>
			</div>
			"""

		# Canvas - used to draw the backdrop
		@canvas = document
			.getElementById("spideyCanvas")
			.getContext("2d")

		# Setup initial UI
		@rebuildUI()
		return

	setResizeCallback: (@resizeCallback) ->
		return

	rebuildUI: =>

		# Scale everything to maximise screen utilisation
		@dispHeight = window.innerHeight - 10
		@dispWidth = window.innerWidth - 10
		@isLandscape = @dispWidth > @dispHeight
		origImgRatio = @origBackdropSize.width/@origBackdropSize.height
		screenRatio = @dispWidth/@dispHeight
		if origImgRatio < screenRatio
			scaleHeight = @dispHeight
			scaleWidth = @dispHeight * origImgRatio
		else
			scaleWidth = @dispWidth
			scaleHeight = @dispWidth / origImgRatio
		@joystickSize = scaleWidth/3
		@canvasLeft = (@dispWidth - scaleWidth) / 2
		@canvasTop = (@dispHeight - scaleHeight) / 2
		@canvasWidth = scaleWidth
		@canvasHeight = scaleHeight
		@scaleFactorX = @canvasWidth / @origBackdropSize.width
		@scaleFactorY = @canvasHeight / @origBackdropSize.height

		# Canvas and sprite overlay occupy the same screen area
		$("#spideyCanvas").prop
			"width":@canvasWidth
			"height":@canvasHeight
		$("#spideyCanvas").css
			"left": @canvasLeft + "px" 
			"top": @canvasTop + "px"
			"width": @canvasWidth + "px" 
			"height": @canvasHeight + "px"
		$("#spriteOverlay").css
			"left": @canvasLeft + "px" 
			"top": @canvasTop + "px"
			"width": @canvasWidth + "px" 
			"height": @canvasHeight + "px"
		$("#gamebuttons").css
			"left": @canvasLeft + 10 + "px" 
			"top": @canvasTop + (0.76*@canvasHeight) + "px"
			"width": @joystickSize+ "px" 
			"height": @joystickSize + "px"
		$("#gameScore").css
			"left": @canvasLeft + @canvasWidth * 0.70 + "px" 
			"top": @canvasTop + (0.06*@canvasHeight) + "px"
			"width": 140 + "px" 
			"font-size": 50 + "px"
			"font-family": 'Calligraffitti'

		# Re-show the game backdrop as resizing the canvas clears it
		@showGameBackdrop()

		# Callback to allow other game elements to resize
		if @resizeCallback?
			@resizeCallback()

		# TEST TEST
		if testtest?

			@canvas.fillStyle = "black"
			@canvas.fillRect(0, 0, @canvasWidth, @canvasHeight)
			@canvas.fillStyle = "green"
			@canvas.fillRect(400, 700, 20, 20)

			$("#spriteOverlay").append """
				<div id="dot_0000"
					style="position:absolute; visibility:visible; left:400px; top:700px" >
			        <svg width="20px" height="20px">
			             <circle cx="10" cy="10" r="10" stroke="black" stroke-width="0" fill="yellow"/>
			        </svg>
			    </div>
			"""

		return

	getPositionOfSprite: (xyInSpideyWallUnits) ->
		# Scale to sprite overlay units
		xyOfSprite =
			x: xyInSpideyWallUnits.x * @scaleFactorX
			y: xyInSpideyWallUnits.y * @scaleFactorY
		return xyOfSprite

	getSpideyWallCoords: (xyInSpriteUnits) ->
		# Scale from sprite overlay units
		xyOfSpidey =
			x: xyInSpriteUnits.x / @scaleFactorX
			y: xyInSpriteUnits.y / @scaleFactorY
		return xyOfSpidey		

	setDirectionCallback: (@directionCallback) ->
		return

	updateJoystickBallUI: (joystickDirn, joystickDist) ->
		if not joystickDist?
			joystickDist = 100
		ballSize = @joystickSize/2
		ballMarginX = @joystickSize / 2 - ballSize/2
		ballMarginY = @joystickSize / 2 - ballSize/2
		ballMoveRadius = @joystickSize / 5

		# Add direction of current movement
		if joystickDirn?
			dirnInRads = joystickDirn * Math.PI / 180
			ballOffset = Math.min(joystickDist, ballMoveRadius)
			ballMarginX += Math.cos(dirnInRads) * ballOffset
			ballMarginY += Math.sin(dirnInRads) * ballOffset

		# Position the graphic
		$("#sqJoystickBall img").css
			"margin-left": ballMarginX + "px" 
			"margin-top": ballMarginY + "px"
			"width": ballSize + "px" 
			"height": ballSize + "px"
		return

	mouseMoveJoystick: (event) =>
		# event holds the required location of the ball
		ballCentreX = @joystickSize / 2
		ballCentreY = @joystickSize / 2
		joystickPos = $(".sqJoystick").offset()
		relX = event.pageX - joystickPos.left
		relY = event.pageY - joystickPos.top
		joystickDirn = Math.atan2(relY - ballCentreY, relX - ballCentreX) * 180 / Math.PI
		joystickDist = Math.sqrt((relY - ballCentreY)*(relY - ballCentreY)+(relX - ballCentreX)*(relX - ballCentreX))
		@directionCallback(joystickDirn, joystickDist)
		return

	touchMoveJoystick: (event) =>
		event.preventDefault()
		if event.originalEvent.touches.length is 1
			pagePos =
				pageX: event.originalEvent.touches[0].pageX
				pageY:  event.originalEvent.touches[0].pageY
			@mouseMoveJoystick(pagePos)
		return

	touchStartJoystick: (event) =>
		event.preventDefault()
		return

	showGameUI: (showIt) ->
		$("#gamebuttons").show()
		@showGameBackdrop()
		@showGamePad(200,100)
		return

	showGamePad: (tlx, tly) ->
		$("#gamebuttons").append """
			<div class="sqJoystick" style="display:block; opacity:1;">
				<div class="sqJoystickImg" style="position:absolute;" >
					<img width="100%" height="100%" src="img/joystickbase.png"></img>
				</div>
				<div id="sqJoystickBall" style="position:absolute;" >
					<img width="50%" height="50%" src="img/joystickball.png" style="margin-top:30%;margin-left:31%"></img>
				</div>
			</div>
			"""
		$(".sqJoystick").on "mousemove", @mouseMoveJoystick
		$(".sqJoystick").on "touchstart", @touchStartJoystick
		$(".sqJoystick").on "touchmove", @touchMoveJoystick
		return

	showGameBackdrop: () ->
		# Clear canvas
		@canvas.fillStyle = "black"
		@canvas.fillRect(0, 0, @canvasWidth, @canvasHeight)

		# Draw the maze in blue to create the walls
		@canvas.lineWidth = @canvasHeight / 30
		for link, linkIdx in @spideyWall.getLinks()
			@canvas.beginPath()
			@canvas.moveTo(link.xSource * @scaleFactorX, link.ySource * @scaleFactorY)
			@canvas.lineTo(link.xTarget * @scaleFactorX, link.yTarget * @scaleFactorY)
			@canvas.strokeStyle = "blue"
			@canvas.stroke()
			# console.log "xyxy " + link.xSource * @scaleFactorX + " " + link.ySource * @scaleFactorY

		# Draw the maze again in black but this time with narrower lines 
		@canvas.lineWidth = @canvasHeight / 50
		for link in @spideyWall.getLinks()
			@canvas.beginPath()
			@canvas.moveTo(link.xSource *  @scaleFactorX, link.ySource * @scaleFactorY)
			@canvas.lineTo(link.xTarget * @scaleFactorX, link.yTarget * @scaleFactorY)
			@canvas.strokeStyle = "black"
			@canvas.stroke()

		return 

	showGameOver: () ->
		# Display game-over popup
		popWid = @canvasWidth/2
		popHig = @canvasHeight/10
		popTop = @canvasTop + @canvasHeight/3-popHig/2
		popLeft = @canvasLeft + @canvasWidth/2-popWid/2
		$("body").append """
			<div id="gameoverpopup" style="display:block; opacity:1;
		        position: absolute;
		        width: #{popWid}px;
		        height: #{popHig}px;
		        background: #000000;
		        color: yellow;
		        border: 10px solid yellow;
		        border-radius: 10px;
		        padding: 15px 17px;
		        margin: 10% auto;
		        top: #{popTop}px;
		        left: #{popLeft}px;">
				<div style="text-align: center">
					<img width="100%" height="100%" src="img/gameoverplayagain.png" style=""></img>
				</div>
			</div>
			"""
		$("#gameoverpopup").on "click", =>
			$("#gameoverpopup").remove()
			@restartCallback()
		return
