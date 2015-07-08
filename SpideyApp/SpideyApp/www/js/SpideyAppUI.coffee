class SpideyAppUI
	constructor: () ->
		@mediaPlayHelper = new MediaPlayHelper(
			{
				click: "assets/click.mp3",
				ok: "assets/blip.mp3",
				fail: "assets/fail.mp3"
			})
		@origBackdropSize =
			width: 504
			height: 720
		@curJoystickDirn = null
		@curJoystickDist = 0

	init: (spideyWall) ->
		# CSS
		$("html").css
			background: "#000000"
		# Basic body for DOM
		$("body").prepend """
			<div id="sqWrapper">
		        <canvas id="spideyCanvas" 
		        	width="#{@origBackdropSize.width}" 
		        	height="#{@origBackdropSize.height}" 
		        	style="position: absolute; left: 0px; border: 0px; "></canvas>
				<div id="gamesAvailable">
				</div>
				<div id="gamebuttons" style="position:absolute;">
				</div>
			</div>
			"""

		canvas = document
			.getElementById("spideyCanvas")
			.getContext("2d")
		spideyWall.setCanvas(canvas)
	
		# Handler for orientation change
		$(window).on 'orientationchange', =>
		  @rebuildUI()
		# And resize event
		$(window).on 'resize', =>
		  @rebuildUI()

		@buttonColours = [ "red", "green", "blue", "brown" ]
		@nextButtonColour = 0

		@gamesAvail = {}
		@rebuildUI()

	rebuildUI: =>
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
		canvasLeft = (@dispWidth - scaleWidth) / 2
		canvasTop = (@dispHeight - scaleHeight) / 2	
		@joystickSize = scaleWidth/3 

		# canvasHeight = if @isLandscape @dispHeight
		$("#spideyCanvas").css
			"left": canvasLeft + "px" 
			"top": canvasTop + "px"
			"width": scaleWidth + "px" 
			"height": scaleHeight + "px"
		$("#gamebuttons").css
			"left": canvasLeft + 10 + "px" 
			"top": canvasTop + (0.76*scaleHeight) + "px"
			"width": @joystickSize+ "px" 
			"height": @joystickSize + "px"

		return

	setJoystickBall: () ->
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

		$("#sqJoystickBall img").css
			"margin-left": ballMarginX + "px" 
			"margin-top": ballMarginY + "px"
			"width": ballSize + "px" 
			"height": ballSize + "px"
		return

	mouseMoveJoystick: (event) =>
		ballCentreX = @joystickSize / 2
		ballCentreY = @joystickSize / 2
		joystickPos = $(".sqJoystick").offset()
		relX = event.pageX - joystickPos.left
		relY = event.pageY - joystickPos.top
		@curJoystickDirn = Math.atan2(relY - ballCentreY, relX - ballCentreX) * 180 / Math.PI
		@curJoystickDist = Math.sqrt((relY - ballCentreY)*(relY - ballCentreY)+(relX - ballCentreX)*(relX - ballCentreX))
		# console.log relX, relY, @curJoystickDirn
		@setJoystickBall()
		return

	showGameUI: (showIt) ->
		$("#gamebuttons").show()
		return

	showGamePad: (tlx, tly, @directionCallback, small) ->
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
