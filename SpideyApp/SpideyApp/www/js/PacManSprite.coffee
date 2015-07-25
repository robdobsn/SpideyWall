# Sprite class - handles both the pacman character and the ghosts

class PacManSprite

	constructor: (@name, @initialNodeIdx, @leaveHouseDots, @minFollowDist, @colour, @isPacman, @moveAlgo, @ghostHouseNode, @spideyWall, @spideyAppUI) ->
		@curLocation =
			nodeIdx: if @isPacman then @initialNodeIdx else @ghostHouseNode
			linkIdx: -1
			linkStep: 0
			stepSize: 1
		@userReqdDirection = 0
		@angleOfTravel = 0
		@spriteSizePx = 25
		@isVisible = @isPacman
		@dotsEatenWhenLastSentHome = 0
		@justWrapped = false
		return
 
	showInitially: () ->
		if @isPacman
			$("#spriteOverlay").append """
				<div id="sprite_#{@name}" style="position:absolute; visibility:hidden" >
			        <svg viewBox="-140 -80 150 100" width="#{@spriteSizePx}px" height="#{@spriteSizePx}px">
			            <path
			           style="fill:#{@colour};stroke:#{@colour};stroke-width:0;
			           				stroke-miterlimit:4;opacity:1.0"
			           d="m 0,0 
			              c -16.86408,33.1589 -57.645487,46.4843 -91.087814,29.7632 -33.44233,-16.7212 -46.8816569,-57.157 -30.017575,-90.3159 16.864081,-33.1589 57.645482,-46.4844 91.087819,-29.7632 12.54879,6.2744 22.82161,16.2595 29.39805,28.5746
			           	  l -69.792329,31.4649 z"
			            />
			        </svg>
			    </div>
			"""
		else
			$("#spriteOverlay").append """
				<div id="sprite_#{@name}" style="position:absolute; visibility:hidden">
			        <svg viewBox="-10 -100 170 100" width="#{@spriteSizePx}px" height="#{@spriteSizePx}px">
			            <path
			           style="fill:#{@colour};stroke:#{@colour};stroke-width:0;
			           				stroke-miterlimit:4;opacity:0.9"
			           d="m 0,0 
			              c -5.49953,-27.1434 1.05933,-123.834 67.82924,-122.9885 66.7699,0.8455 73.54087,94.0287 71.25122,121.2808 -2.28965,27.2521 -9.83924,20.9719 -14.93596,18.3842 -5.09672,-2.5877 -16.08257,-16.6765 -26.44335,-16.6765 -10.36078,0 -13.51175,15.1164 -24.13793,16.092 -10.62618,0.9756 -22.16027,-14.3948 -32.18391,-13.7931 -10.02364,0.6017 -16.62397,9.2152 -21.83908,12.6437 -5.21511,3.4285 -14.0407,12.2008 -19.54023,-14.9426 z"
			           />
			        </svg>
			    </div>
			"""

	copyLocation: ->
		@oldLocation =
			node: @curLocation.nodeIdx
			linkIdx: @curLocation.linkIdx
			linkStep: @curLocation.linkStep
		return

	setDirection: (dirn) ->
		@userReqdDirection = dirn

	resizeUI: () ->
		@updateUI()
		return

	updateUI: (gameMode, gameCounter, frightenedInterval) ->

		# Show sprite at location
		xyPos = @getPositionXY()
		if xyPos?
			# Get position on UI
			spriteXY = @spideyAppUI.getPositionOfSprite(xyPos)
			$("#sprite_#{@name}").css
				"visibility": if @isVisible then 'visible' else 'hidden'
				"top": spriteXY.y - @spriteSizePx/2 + "px"
				"left": spriteXY.x - @spriteSizePx/2 + "px"
			if not @isPacman and gameMode? and gameCounter?
				if gameMode is 'frightened'
					if gameCounter < frightenedInterval * 0.75
						fillColour = "#551A8B"
					else
						colrMod = ((frightenedInterval - gameCounter) % 10) * 30
						fillColour = "##{@toHex(colrMod + 80, 2)}1A#{@toHex(colrMod + 120, 2)}"
				else
					fillColour = @colour
				$("#sprite_#{@name} svg path").css
					"fill": fillColour
		return

	toHex: (val, digits) ->
		 return ("00000000" + val.toString(16)).slice(-digits);

	dist: (x1, y1, x2, y2) ->
		return Math.sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)))

	angle: (x1, y1, x2, y2) ->
		return Math.atan2(y2-y1, x2-x1) * 180 / Math.PI

	sendBackHome: (dotsEaten) ->
		@moveToNode(@ghostHouseNode)
		@isVisible = false
		@dotsEatenWhenLastSentHome = dotsEaten
		return

	moveToNode: (nodIdx) ->
		@curLocation.nodeIdx = nodIdx
		@curLocation.linkIdx = -1
		@curLocation.linkStep = 0
		return

	getPositionXY: (sprite) ->
		if not sprite?
			sprite = this
		xyPos = @spideyWall.getPositionXY(sprite.curLocation.nodeIdx, sprite.curLocation.linkIdx, sprite.curLocation.linkStep)
		return xyPos

	getPositionPointIdx: (sprite) ->
		if not sprite?
			sprite = this
		return @spideyWall.getPositionPointIdx(sprite.curLocation.nodeIdx, sprite.curLocation.linkIdx, sprite.curLocation.linkStep)

	movePacman: () ->

		# Make a copy of the location so we can see where we came from
		@copyLocation()

		# Check if we're currently at a node
		if @curLocation.linkIdx < 0
			# We are currently at a node
			# console.log "Dirn " + @userReqdDirection + " lastDir " + if @angleOfTravel? then @angleOfTravel else "NO"
			bestLinkIdx = 0

			# Check if we're heading off the edge of the map - only 1 link at a node
			numLinksFromHere = @spideyWall.getNumLinks(@curLocation.nodeIdx)
			if numLinksFromHere == 1 and not @justWrapped
				# console.log "heading off the map nodeIdx=" + @curLocation.nodeIdx
				# Wrap to another node
				@curLocation.nodeIdx = @spideyWall.getWrapNodeIdx(@curLocation.nodeIdx)
				@curLocation.linkIdx = -1
				@curLocation.linkStep = 0
				@curLocation.stepSize = 1
				@justWrapped = true
			else

				# Find the link which most closely approximates the desired angle of travel
				nearestAngle = 360
				for linkIdx in [0...numLinksFromHere]
					# Get link angle ignoring direction we're currently travelling
					linkAngle = @spideyWall.getLinkAngle(@curLocation.nodeIdx, linkIdx, 1)
					# Compute difference between required and link angle - again staying within the -180 to +180 range
					angleDiff = Math.abs(@userReqdDirection-linkAngle)
					angleDiff = if angleDiff > 180 then 360-angleDiff else angleDiff
					# console.log "linkIdx" + linkIdx + " linkAngle = " + linkAngle + " diff " + angleDiff
					# Check whether angle is the best we've got
					if nearestAngle	> angleDiff
						nearestAngle = angleDiff
						bestLinkIdx	= linkIdx
						# console.log "Best is " + linkIdx
				@curLocation.linkIdx = bestLinkIdx
				@curLocation.linkStep = 0
				@curLocation.stepSize = 1
				@justWrapped = false
			# console.log "At nodeidx " + @curLocation.nodeIdx + "reqd " + @userReqdDirection + " bestLinkIdx " + bestLinkIdx + " angle " + nearestAngle 

			# Set current angle of travel
			if @curLocation.linkIdx isnt -1
				@angleOfTravel = @spideyWall.getLinkAngle(@curLocation.nodeIdx, @curLocation.linkIdx, @curLocation.stepSize)
				# console.log "at node angleOfTravel " + @angleOfTravel

		else

			# Get angle we were travelling in
			@angleOfTravel = @spideyWall.getLinkAngle(@curLocation.nodeIdx, @curLocation.linkIdx, @curLocation.stepSize)
			# console.log "angleOfTravel " + @angleOfTravel

			# We're currently on a link see if reverse required
			angleDiff = Math.abs(@userReqdDirection-@angleOfTravel)
			angleDiff = if angleDiff > 180 then 360-angleDiff else angleDiff
			# console.log "angleOfTravel " + @angleOfTravel + " required " + @userReqdDirection + " angleDiff " + angleDiff
			if angleDiff < -140 or angleDiff > 140
				# Check for reverse
				# console.log "REVERSE " + @angleOfTravel + " " + angleDiff
				@curLocation.stepSize = -@curLocation.stepSize

			@angleOfTravel = @spideyWall.getLinkAngle(@curLocation.nodeIdx, @curLocation.linkIdx, @curLocation.stepSize)
			# console.log "angleOfTravel " + @angleOfTravel
			# Move further along the path
			@curLocation.linkStep += @curLocation.stepSize
			# console.log "on path from node " + @curLocation.nodeIdx+ " step " + @curLocation.linkIdx + " link " + @curLocation.linkStep + " len = " + @spideyWall.getLinkLength(@curLocation.nodeIdx, @curLocation.linkIdx)
			if (@curLocation.linkStep < 0) or (@curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.nodeIdx, @curLocation.linkIdx))
				# Check if we've reached the end of the path
				if (@curLocation.linkStep >= 0)
					@curLocation.nodeIdx = @spideyWall.getLinkTarget(@curLocation.nodeIdx, @curLocation.linkIdx)
				@curLocation.linkIdx = -1
				@curLocation.linkStep = 0
			@justWrapped = false
		return

	moveGhost: (gameMode, pacmanChomper, blinkyGhost, dotsEaten) ->
		# Check if pacman should be made visible
		if not @isVisible
			# Based on number of dots eaten
			if dotsEaten - @dotsEatenWhenLastSentHome > @leaveHouseDots
				@isVisible = true
				console.log "DotsEaten " + dotsEaten + " make " + @name + " visisble"
			else
				return false

		# Check if ghost is at same location as pacman
		if @getPositionPointIdx(pacmanChomper) is @getPositionPointIdx()
			return true

		# Check if we're at a node (linkIdx == -1)
		@copyLocation()
		if @curLocation.linkIdx < 0
			# Get Pacman location
			pacmanXY = @getPositionXY(pacmanChomper)
			targetXY =
				x: pacmanXY.x
				y: pacmanXY.y
			# Check game mode
			if gameMode is 'scatter'
				targetXY = @spideyWall.getNodeXY(@initialNodeIdx)
			else if gameMode is 'frightened'
				numLinks = @spideyWall.getNumLinks(@curLocation.nodeIdx)
				linkIdx = Math.floor(Math.random() * numLinks)
				linkTarget = @spideyWall.getLinkTarget(@curLocation.nodeIdx, linkIdx)
				targetXY = @spideyWall.getNodeXY(linkTarget)
			else if gameMode is 'chase'
				# Blinky (red) goes straight for pacman
				# Pinky (pink) goes for 4 steps ahead
				if @moveAlgo is 1
					numStepsAhead = 4
					theta = pacmanChomper.angleOfTravel * Math.PI / 180
					# angles are measured clockwise from East
					x = Math.cos(theta) * numStepsAhead * @spideyWall.getStepDist()
					y = Math.sin(theta) * numStepsAhead * @spideyWall.getStepDist()
					targetXY.x += x
					targetXY.y += y
				# Inky targets a square which lies 2x a vector between Blinky and two steps ahead of pacman
				# Described here http://gameinternals.com/post/2072558330/understanding-pac-man-ghost-behavior
				if @moveAlgo is 2
					numStepsAhead = 2
					theta = pacmanChomper.angleOfTravel * Math.PI / 180
					# angles are measured clockwise from East
					x = pacmanXY.x + Math.cos(theta) * numStepsAhead * @spideyWall.getStepDist()
					y = pacmanXY.y + Math.sin(theta) * numStepsAhead * @spideyWall.getStepDist()
					# Blinky angle
					blinkyPos = @getPositionXY(blinkyGhost)
					targetXY =
						x: blinkyPos.x + (x - blinkyPos.x) * 2
						y: blinkyPos.y + (y - blinkyPos.y) * 2
				# Clyde targets the same location as Blinky unless he's within a certain distance of
				# Pacman in which case he heads to his home node
				if @moveAlgo is 3
					ownXY = @getPositionXY()
					distFromPacman = Math.sqrt(Math.pow(pacmanXY.x-ownXY.x,2)+Math.pow(pacmanXY.y-ownXY.y,2))
					if distFromPacman < @minFollowDist * @spideyWall.getStepDist()
						targetXY = @spideyWall.getNodeXY(@initialNodeIdx)

			# Find ghost target location
			minDist = 100000
			bestLinkIdx = 0
			# console.log "ghostatnode " + @curLocation.nodeIdx + " numlinks " + @spideyWall.getNumLinks(@curLocation.nodeIdx) + "Me " + meXY.x + " " + meXY.y
			for linkIdx in [0...@spideyWall.getNumLinks(@curLocation.nodeIdx)]
				linkTarget = @spideyWall.getLinkTarget(@curLocation.nodeIdx, linkIdx)
				linkTargetXY = @spideyWall.getNodeXY(linkTarget)
				linkDist = @dist(targetXY.x, targetXY.y, linkTargetXY.x, linkTargetXY.y)
				# console.log "LnkTarget " + linkTargetXY.x + " " + linkTargetXY.y + " dist = " + linkDist
				if minDist > linkDist
					minDist	= linkDist
					bestLinkIdx	= linkIdx
					# console.log "Best" + linkIdx
			@curLocation.linkIdx = bestLinkIdx
			@curLocation.linkStep = 0
		else
			@curLocation.linkStep += 1
			if @curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.nodeIdx, @curLocation.linkIdx)
				@curLocation.nodeIdx = @spideyWall.getLinkTarget(@curLocation.nodeIdx, @curLocation.linkIdx)
				@curLocation.linkIdx = -1
				@curLocation.linkStep = 0

		# Check if ghost is at same location as pacman
		if @getPositionPointIdx(pacmanChomper) is @getPositionPointIdx()
			return true

		return false
