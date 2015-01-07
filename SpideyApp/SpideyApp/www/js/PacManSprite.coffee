class PacManSprite
	constructor: (@name, initialNode, @colour, @spideyWall) ->
		@curLocation = 
			node: initialNode
			linkIdx: -1
			linkStep: 0
		@curDirection =
			move: "forward"
			turn: "none"
		return

	copyLocation: ->
		@oldLocation =
			node: @curLocation.node
			linkIdx: @curLocation.linkIdx
			linkStep: @curLocation.linkStep
		return

	show: ->
		# Clear previous
		if @oldLocation?
			if @oldLocation.linkIdx < 0
				@spideyWall.setNodeColour(@oldLocation.node, false, @colour)
			else
				@spideyWall.setLinkColour(@oldLocation.node, @oldLocation.linkIdx, @oldLocation.linkStep, false, @colour)

		# Show new
			if @curLocation.linkIdx < 0
				@spideyWall.setNodeColour(@curLocation.node, true, @colour)
			else
				@spideyWall.setLinkColour(@curLocation.node, @curLocation.linkIdx, @curLocation.linkStep, true, @colour)
		return

	getXY: () ->
		if @curLocation.linkIdx < 0
			return @spideyWall.getNodeXY(@curLocation.node)
		return @spideyWall.getLinkLedXY(@curLocation.node, @curLocation.linkIdx, @curLocation.linkStep)

	dist: (x1, y1, x2, y2) ->
		return Math.sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)))

	angle: (x1, y1, x2, y2) ->
		return Math.atan2(y2-y1, x2-x1) * 180 / Math.PI

	moveMe: () ->
		@copyLocation()
		if @curLocation.linkIdx < 0
			console.log "Dirn " + @curDirection.move + "/" + @curDirection.turn + " lastDir " + if @angleOfTravel? then @angleOfTravel else "NO"
			bestLinkIdx = 0
			if @angleOfTravel?
				reqdAngle = if @curDirection.turn is "right" then @angleOfTravel+90 else if @curDirection.turn is "left" then @angleOfTravel-90 else @angleOfTravel
				reqdAngle = if reqdAngle > 180 then reqdAngle-360 else if reqdAngle	< -180 then reqdAngle+360 else reqdAngle
				console.log "reqdAngle = " + reqdAngle
				meXY = @getXY()
				nearestAngle = 360
				for linkIdx in [0...@spideyWall.getNumLinks(@curLocation.node)]
					endOfLinkLen = @spideyWall.getLinkLength(@curLocation.node, linkIdx)
					if endOfLinkLen > 0
						edgeEndXY = @spideyWall.getLinkLedXY(@curLocation.node, linkIdx, endOfLinkLen-1)
						#console.log "Bad " + edgeEndXY.x + " " + edgeEndXY.y
						linkAngle = @angle(meXY.x, meXY.y, edgeEndXY.x, edgeEndXY.y)
					else
						nextNode = @spideyWall.getLinkTarget(@curLocation.node, linkIdx)
						nextNodeXY = @spideyWall.getNodeXY(nextNode)
						linkAngle = @angle(meXY.x, meXY.y, nextNodeXY.x, nextNodeXY.y)
					angleDiff = Math.abs(reqdAngle-linkAngle)
					angleDiff = if angleDiff > 180 then 360-angleDiff else angleDiff
					console.log "linkAngle = " + linkAngle + " diff " + angleDiff
					if nearestAngle	> angleDiff
						nearestAngle = angleDiff
						bestLinkIdx	= linkIdx
						console.log "Best is " + linkIdx
			@curLocation.linkIdx = bestLinkIdx
			@curLocation.linkStep = 0
		else
			if @curDirection.move is "back"
				@curLocation.linkStep -= 1
				if @curLocation.linkStep < 0
					@curLocation.linkStep = 0
					@curLocation.linkIdx = -1
					@curDirection.move = "forward"
			else
				@curLocation.linkStep += 1
				if @curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.node, @curLocation.linkIdx)
					@curLocation.node = @spideyWall.getLinkTarget(@curLocation.node, @curLocation.linkIdx)
					@curLocation.linkIdx = -1
					@curLocation.linkStep = 0
			if @curLocation.linkIdx	< 0
				# Get angle we were travelling in
				if @spideyWall.getLinkLength(@oldLocation.node, @oldLocation.linkIdx) > 0
					pointA = @spideyWall.getLinkLedXY(@oldLocation.node, @oldLocation.linkIdx, 0)
				else
					pointA = @spideyWall.getNodeXY(@oldLocation.node)
				if @spideyWall.getLinkLength(@oldLocation.node, @oldLocation.linkIdx) > 1
					endOfLink = @spideyWall.getLinkLength(@oldLocation.node, @oldLocation.linkIdx)-1
					pointB = @spideyWall.getLinkLedXY(@oldLocation.node, @oldLocation.linkIdx, endOfLink)
				else
					nextNode = @spideyWall.getLinkTarget(@oldLocation.node, @oldLocation.linkIdx)
					pointB = @spideyWall.getNodeXY(nextNode)
				@angleOfTravel = @angle(pointA.x, pointA.y, pointB.x, pointB.y)
		return

	moveBaddie: (me) ->
		@copyLocation()
		if @curLocation.linkIdx < 0
			# Find which edge takes me closer to ME
			meXY = me.getXY()
			minDist = 100000
			bestLinkIdx = 0
			#console.log "Me " + meXY.x + " " + meXY.y
			for linkIdx in [0...@spideyWall.getNumLinks(@curLocation.node)]
				endOfLinkLen = @spideyWall.getLinkLength(@curLocation.node, linkIdx)
				if endOfLinkLen > 0
					edgeEndXY = @spideyWall.getLinkLedXY(@curLocation.node, linkIdx, endOfLinkLen-1)
					#console.log "Bad " + edgeEndXY.x + " " + edgeEndXY.y
					linkDist = @dist(meXY.x, meXY.y, edgeEndXY.x, edgeEndXY.y)
					if minDist > linkDist
						minDist	= linkDist
						bestLinkIdx	= linkIdx
			@curLocation.linkIdx = bestLinkIdx
			@curLocation.linkStep = 0
		else
			@curLocation.linkStep += 1
			if @curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.node, @curLocation.linkIdx)
				@curLocation.node = @spideyWall.getLinkTarget(@curLocation.node, @curLocation.linkIdx)
				@curLocation.linkIdx = -1
				@curLocation.linkStep = 0
		return
