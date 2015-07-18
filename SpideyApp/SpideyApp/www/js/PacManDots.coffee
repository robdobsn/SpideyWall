class PacManDots
	constructor: (@gameDots, @dotSize, @spideyWall, @spideyAppUI) ->
		return
 
	showInitially: () ->
		@createOrUpdate(true)
		return

	resizeUI: () ->
		@createOrUpdate(false)
		return

	createOrUpdate: (create) ->
		dotSizeDiv2 = @dotSize/2
		points = @spideyWall.getPoints()
		for dot, dotIdx in @gameDots
			dotPoint = points[dotIdx]
			spriteXY = @spideyAppUI.getPositionOfSprite(dotPoint)
			spriteXY.x -= dotSizeDiv2
			spriteXY.y -= dotSizeDiv2
			if create
				$("#spriteOverlay").append """
					<div id="dot_#{dotIdx}" 
						style="position:absolute; visibility:visible; top:#{spriteXY.y}px; left:#{spriteXY.x}px; width:#{@dotSize}px; height:#{@dotSize}px" >
				        <svg style="position:absolute" width="#{@dotSize}px" height="#{@dotSize}px">
				             <circle cx="#{dotSizeDiv2}" cy="#{dotSizeDiv2}" r="#{dotSizeDiv2}" stroke-width="0" fill="yellow"/>
				        </svg>
				    </div>
				"""
			else
				$("#dot_#{dotIdx}").css
					top: spriteXY.y
					left: spriteXY.x
			console.log "pt " + spriteXY.x + " " + spriteXY.y
		return
