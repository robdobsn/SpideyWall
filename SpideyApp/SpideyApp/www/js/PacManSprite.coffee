class PacManSprite
	constructor: (@name, initialNode, @colour, @spideyWall) ->
		@curLocation =
			node: initialNode
			linkIdx: -1
			linkStep: 0
		@curDirection =
			move: "forward"
			turn: "none"
		@angleOfTravel = 0
		return

	copyLocation: ->
		@oldLocation =
			node: @curLocation.node
			linkIdx: @curLocation.linkIdx
			linkStep: @curLocation.linkStep
		return

	show: ->
		# Clear previous
		# if @oldLocation?
		# 	if @oldLocation.linkIdx < 0
		# 		@spideyWall.setNodeColour(@oldLocation.node, false, @colour)
		# 	else
		# 		@spideyWall.setLinkColour(@oldLocation.node, @oldLocation.linkIdx, @oldLocation.linkStep, false, @colour)

		# Show new
		if @curLocation.linkIdx < 0
			@spideyWall.setNodeColour(@curLocation.node, true, @colour)
		else
			@spideyWall.setLinkColour(@curLocation.node, @curLocation.linkIdx, @curLocation.linkStep, true, @colour)
		return

	dist: (x1, y1, x2, y2) ->
		return Math.sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)))

	angle: (x1, y1, x2, y2) ->
		return Math.atan2(y2-y1, x2-x1) * 180 / Math.PI

	moveMe: () ->
		# Make a copy of the location so we can see where we came from
		@copyLocation()

		# Check if we're currently at a node
		if @curLocation.linkIdx < 0
			# We are currently at a node
			# console.log "Dirn " + @curDirection.move + "/" + @curDirection.turn + " lastDir " + if @angleOfTravel? then @angleOfTravel else "NO"
			bestLinkIdx = 0

			# Work out the angle we want to proceed in - based on the previous angle of travel and any turn commands
			reqdAngle = if @curDirection.turn is "right" then @angleOfTravel+90 else if @curDirection.turn is "left" then @angleOfTravel-90 else @angleOfTravel

			# Make sure the required angle is in the range -180 to +180
			reqdAngle = if reqdAngle > 180 then reqdAngle-360 else if reqdAngle	< -180 then reqdAngle+360 else reqdAngle
			# console.log "reqdAngle = " + reqdAngle

			# Find the link which most closely approximates the desired angle of travel
			nearestAngle = 360
			for linkIdx in [0...@spideyWall.getNumLinks(@curLocation.node)]
				linkAngle = @spideyWall.getLinkAngle(@curLocation.node, linkIdx)
				# Compute difference between required and link angle - again staying within the -180 to +180 range
				angleDiff = Math.abs(reqdAngle-linkAngle)
				angleDiff = if angleDiff > 180 then 360-angleDiff else angleDiff
				# console.log "linkAngle = " + linkAngle + " diff " + angleDiff
				# Check whether angle is the best we've got
				if nearestAngle	> angleDiff
					nearestAngle = angleDiff
					bestLinkIdx	= linkIdx
					# console.log "Best is " + linkIdx
			@curLocation.linkIdx = bestLinkIdx
			@curLocation.linkStep = 0
		else
			# We're currently on a link
			if @curDirection.move is "back"
				# Check for reverse
				@curLocation.linkStep -= 1
				if @curLocation.linkStep < 0
					# Have we now hit a node?
					@curLocation.linkStep = 0
					@curLocation.linkIdx = -1
					@curDirection.move = "forward"
			else
				# Move further along the path
				@curLocation.linkStep += 1
				# console.log "on path from node " + @curLocation.node + " step " + @curLocation.linkIdx + " link " + @curLocation.linkStep + " len = " + @spideyWall.getLinkLength(@curLocation.node, @curLocation.linkIdx)
				if @curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.node, @curLocation.linkIdx)
					# Check if we've reached the end of the path
					@curLocation.node = @spideyWall.getLinkTarget(@curLocation.node, @curLocation.linkIdx)
					@curLocation.linkIdx = -1
					@curLocation.linkStep = 0
			if @curLocation.linkIdx	< 0
				# Get angle we were travelling in
				@angleOfTravel = @spideyWall.getLinkAngle(@oldLocation.node, @oldLocation.linkIdx)
		return

	moveBaddie: (me) ->
		@copyLocation()
		if @curLocation.linkIdx < 0
			# Find which edge takes the baddie closer to ME
			meXY = @spideyWall.getNodeXY(me.curLocation.node)
			minDist = 100000
			bestLinkIdx = 0
			# console.log "BaddieAtnode " + @curLocation.node + " numlinks " + @spideyWall.getNumLinks(@curLocation.node) + "Me " + meXY.x + " " + meXY.y
			for linkIdx in [0...@spideyWall.getNumLinks(@curLocation.node)]
				linkTarget = @spideyWall.getLinkTarget(@curLocation.node, linkIdx)
				linkTargetXY = @spideyWall.getNodeXY(linkTarget)
				linkDist = @dist(meXY.x, meXY.y, linkTargetXY.x, linkTargetXY.y)
				# console.log "LnkTarget " + linkTargetXY.x + " " + linkTargetXY.y + " dist = " + linkDist
				if minDist > linkDist
					minDist	= linkDist
					bestLinkIdx	= linkIdx
					# console.log "Best" + linkIdx
			@curLocation.linkIdx = bestLinkIdx
			@curLocation.linkStep = 0
		else
			@curLocation.linkStep += 1
			if @curLocation.linkStep >= @spideyWall.getLinkLength(@curLocation.node, @curLocation.linkIdx)
				@curLocation.node = @spideyWall.getLinkTarget(@curLocation.node, @curLocation.linkIdx)
				@curLocation.linkIdx = -1
				@curLocation.linkStep = 0
		return
