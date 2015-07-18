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
		# Direction the joystick is pointing
		@curJoystickDirn = null
		@curJoystickDist = 0

	init: (@spideyWall) ->
		# CSS for black background
		$("html").css
			background: "#000000"
		# Basic body for DOM
		$("body").prepend """
			<div id="gameArea">
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
	
		# Handler for orientation change
		$(window).on 'orientationchange', =>
		  @rebuildUI()
		# And resize event
		$(window).on 'resize', =>
		  @rebuildUI()

		# Setup initial UI
		@rebuildUI()
		return

	setResizeCallback: (@resizeCallback) ->
		return

	rebuildUI: =>
		# Scale everything to maximise screen utilisation
		@dispHeight = window.innerHeight
		@dispWidth = window.innerWidth
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

	updateJoystickBallUI: () ->
		ballSize = @joystickSize/2
		ballMarginX = @joystickSize / 2 - ballSize/2
		ballMarginY = @joystickSize / 2 - ballSize/2
		ballMoveRadius = @joystickSize / 5

		# Add direction of current movement
		if @curJoystickDirn?
			dirnInRads = @curJoystickDirn * Math.PI / 180
			ballOffset = Math.min(@curJoystickDist, ballMoveRadius)
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
		@curJoystickDirn = Math.atan2(relY - ballCentreY, relX - ballCentreX) * 180 / Math.PI
		@curJoystickDist = Math.sqrt((relY - ballCentreY)*(relY - ballCentreY)+(relX - ballCentreX)*(relX - ballCentreX))
		@updateJoystickBallUI()
		@directionCallback(@curJoystickDirn)
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
		return

	showGameBackdrop: () ->
		@canvas.fillStyle = "black"
		@canvas.fillRect(0, 0, @canvasWidth, @canvasHeight)
		@canvas.lineWidth = @canvasHeight / 30
		for link, linkIdx in @spideyWall.getLinks()
			@canvas.beginPath()
			@canvas.moveTo(link.xSource * @scaleFactorX, link.ySource * @scaleFactorY)
			@canvas.lineTo(link.xTarget * @scaleFactorX, link.yTarget * @scaleFactorY)
			@canvas.strokeStyle = "blue"
			@canvas.stroke()
			# console.log "xyxy " + link.xSource * @scaleFactorX + " " + link.ySource * @scaleFactorY
				
		@canvas.lineWidth = @canvasHeight / 50
		for link in @spideyWall.getLinks()
			@canvas.beginPath()
			@canvas.moveTo(link.xSource *  @scaleFactorX, link.ySource * @scaleFactorY)
			@canvas.lineTo(link.xTarget * @scaleFactorX, link.yTarget * @scaleFactorY)
			@canvas.strokeStyle = "black"
			@canvas.stroke()

		# nodXY = @spideyWall.getNodeXY(9)
		# @canvas.fillStyle = "green"
		# @canvas.fillRect(nodXY.x *  @scaleFactorX, nodXY.y * @scaleFactorY, 5, 5)
			# for link in @spideyWall.getLinks()
			# 	@canvas.fillStyle = "green"
			# 	@canvas.fillRect(link.xSource *  @scaleFactorX, link.ySource * @scaleFactorY, 2, 2)
