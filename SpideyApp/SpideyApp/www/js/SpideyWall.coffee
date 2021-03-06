# Handle the SpideyWall geometry

class SpideyWall

	constructor: () ->
		@spideyGeometry = window.SpideyGeometry
		@pointsInGeometry = @generatePointInfo()
		@wrapAroundNodeIdxs = null
		@wrapAroundNodes =
			79: 73
			73: 79
			77: 75
			75: 77
			61: 69
			69: 61
			60: 68
			68: 60
			76: 78
			78: 76
			74: 62
			62: 74
			65: 63
			63: 65
			64: 72
			72: 64
			71: 63
			66: 72
			67: 72
			70: 60

	# Access methods to get information about the geometry

	getLinks: () ->
		return @spideyGeometry.links 

	getPoints: () ->
		return @pointsInGeometry

	getNumPoints: () ->
		return @pointsInGeometry.length		

	getWrapNodeIdx: (nodeIdx) ->
		if nodeIdx of @wrapAroundNodes
			return @wrapAroundNodes[nodeIdx]
		return @getRandomEdgeNodeIdx(nodeIdx)

	getRandomEdgeNodeIdx: (nodeIdx) ->
		if not @wrapAroundNodeIdxs?
			@wrapAroundNodeIdxs = []
			for nod, nodIdx in @spideyGeometry.nodes
				if nod.linkIdxs.length == 1
					@wrapAroundNodeIdxs.push nodIdx
		randElem = Math.floor(Math.random() * @wrapAroundNodeIdxs.length)
		if randElem < @wrapAroundNodeIdxs.length
			return @wrapAroundNodeIdxs[randElem]
		return nodeIdx

	getStepDist: () ->
		# Distance (in SpideyGeometry units) of one average step in a link
		return 7

	getNumNodes: () ->
		return @spideyGeometry.nodes.length

	getNodeXY: (nodeIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		return { x: node.x, y: node.y }

	getLinkAngle: (nodeIdx, nodeLinkIdx, moveDirection) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		if not link?
			debugger
		if moveDirection > 0
			return link.linkAngle
		return if link.linkAngle > 0 then link.linkAngle-180 else link.linkAngle+180

	getLinkLedXY: (nodeIdx, nodeLinkIdx, linkStep) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		ledIdx = link.padEdges[0].ledIdxs[linkStep]
		led = @spideyGeometry.leds[ledIdx]
		if not led?
			console.log "Error no led"
		return { x: led.x, y: led.y }

	getNumLinks: (nodeIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		return node.linkIdxs.length

	getLinkLength: (nodeIdx, nodeLinkIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		# Find shortest edge num leds
		edgeLen = 1000
		for padEdge in link.padEdges
			if edgeLen > padEdge.ledIdxs.length
				edgeLen = padEdge.ledIdxs.length
		return edgeLen

	getLinkTarget: (nodeIdx, nodeLinkIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		if not link? or not link.target?
			debugger
		return link.target

	getLinkCofG: (nodeIdx, nodeLinkIdx, linkStep) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		xCofG = 0
		yCofG = 0
		cnt = 0
		# Find the centre of the led xy positions at the appropriate
		# postion along the link
		for edge in link.padEdges
			if linkStep < edge.ledIdxs.length
				ledIdx = edge.ledIdxs[linkStep]
				led = @spideyGeometry.leds[ledIdx]
				xCofG += led.x
				yCofG += led.y
				cnt++
		if cnt is 0
			# Instead use the point half way along the link
			cnt = 2
			xCofG = link.xSource+link.xTarget
			yCofG = link.ySource+link.yTarget
		return { x: xCofG/cnt, y: yCofG/cnt }

	getNodeNearXY: (x, y) ->
		bestDist = 1000000
		bestIdx = -1
		for nod, nodIdx in @spideyGeometry.nodes
			nodXy = @getNodeXY(nodIdx)
			dist = Math.pow(x-nodXy.x,2) + Math.pow(y-nodXy.y,2)
			if bestDist > dist
				bestDist = dist
				bestIdx = nodIdx
		# console.log "nodXy " + @getNodeXY(bestIdx).x + " " + @getNodeXY(bestIdx).y
		return bestIdx

	getPositionXY: (nodeIdx, nodeLinkIdx, linkStep) ->
		xyPos = null
		if nodeLinkIdx < 0
			xyPos = @getNodeXY(nodeIdx)
		else
			xyPos = @getLinkCofG(nodeIdx, nodeLinkIdx, linkStep)
		if not xyPos?
			debugger
		return xyPos

	getPositionPointIdx: (nodeIdx, nodeLinkIdx, linkStep) ->
		if nodeLinkIdx < 0
			if not @spideyGeometry.nodes[nodeIdx].pointIdx?
				debugger
			return @spideyGeometry.nodes[nodeIdx].pointIdx
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		if not link.pointIdxs[linkStep]?
			# This can happen because there are no LEDs between two nodes
			return node.pointIdx
		return link.pointIdxs[linkStep]

	generatePointInfo: () ->
		# For each node and each step in a link generate a unique ID which
		# can be referenced directly
		linksIdxsProcessed = []
		pointList = []
		for nod, nodIdx in @spideyGeometry.nodes
			nod.pointIdx = pointList.length
			pointList.push
				x: nod.x
				y: nod.y
				nodeIdx: nodIdx
				linkIdx: -1
				linkStep: 0
			for nodeLinkIdx in [0...nod.linkIdxs.length]
				# Get link info
				linkIdx = nod.linkIdxs[nodeLinkIdx]
				# Check link not already processed
				if linkIdx not in linksIdxsProcessed
					# Add to list of processed links
					linksIdxsProcessed.push(linkIdx)
					link = @spideyGeometry.links[linkIdx]
					# Find minimum num leds in link
					linkLen = @getLinkLength(nodIdx, nodeLinkIdx)
					# Process the steps as points
					linkPoints = []
					for stepIdx in [0...linkLen]
						linkPoints.push(pointList.length)
						pointInf = @getLinkCofG(nodIdx, nodeLinkIdx, stepIdx)
						pointInf.nodeIdx = nodIdx
						pointInf.linkIdx = nodeLinkIdx
						pointInf.linkStep = stepIdx
						pointList.push(pointInf)
					link.pointIdxs = linkPoints
					# Find the reverse link
					revLnk = null
					for revLnkTest in @spideyGeometry.links
						if revLnkTest.source is link.target and revLnkTest.target is link.source
							linksIdxsProcessed.push(revLnkTest.linkIdx)
							revLnk = revLnkTest
							# Store the points info in reverse for the reverse link
							revLinkPoints = linkPoints.slice(0)
							revLinkPoints.reverse()
							revLnk.pointIdxs = revLinkPoints
							break
		return pointList

	getPointNearXY: (x, y) ->
		bestDist = 1000000
		bestIdx = -1
		for pt, ptIdx in @pointsInGeometry
			dist = Math.pow(x-pt.x,2) + Math.pow(y-pt.y,2)
			if bestDist > dist
				bestDist = dist
				bestIdx = ptIdx
		return bestIdx

	dist: (pt1, pt2) ->
		return Math.sqrt(Math.pow(pt1.x - pt2.x, 2) + Math.pow(pt1.y - pt2.y, 2))
