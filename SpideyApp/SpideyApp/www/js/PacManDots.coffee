class PacManDots
	constructor: (@pillPositions, @dotSize, @dotScore, @spideyWall, @spideyAppUI) ->
		@generateGameDots()
		@dotsEaten = 0
		return
 
	showInitially: () ->
		@createOrUpdate(true)
		return

	resizeUI: () ->
		@createOrUpdate(false)
		return

	createOrUpdate: (create) ->
		points = @spideyWall.getPoints()
		for dot, dotIdx in @gameDots
			dotColor = if dot.dotType is 0 then "white" else "magenta"
			dotSz = if dot.dotType is 0 then @dotSize else @dotSize*3
			dotSzD2 = dotSz/2
			dotPoint = points[dotIdx]
			spriteXY = @spideyAppUI.getPositionOfSprite(dotPoint)
			spriteXY.x -= dotSzD2
			spriteXY.y -= dotSzD2
			if create
				$("#spriteOverlay").prepend """
					<div id="dot_#{dotIdx}" 
						style="position:absolute; visibility:visible; top:#{spriteXY.y}px; left:#{spriteXY.x}px; width:#{@dotSz}px; height:#{dotSz}px" >
				        <svg style="position:absolute" width="#{dotSz}px" height="#{dotSz}px">
				             <circle cx="#{dotSzD2}" cy="#{dotSzD2}" r="#{dotSzD2}" stroke-width="0" fill="#{dotColor}"/>
				        </svg>
				    </div>
				"""
			else
				$("#dot_#{dotIdx}").css
					top: spriteXY.y
					left: spriteXY.x
		return

	getDotsEaten: () ->
		return @dotsEaten

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
				dotScore: @dotScore
		return

	beEaten: (pointIdx) ->
		if not @gameDots[pointIdx]?
			debugger
		dotType = 0
		@dotsEaten += @gameDots[pointIdx].dotScore
		if @gameDots[pointIdx].dotScore isnt 0
			dotType = @gameDots[pointIdx].dotType
		@gameDots[pointIdx].dotScore = 0
		$("#dot_#{pointIdx}").css
			visibility: "hidden"
		return dotType
