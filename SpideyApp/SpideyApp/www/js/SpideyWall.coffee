class SpideyWall
	constructor: (@debugCanvas) ->
		@spideyGeometry = window.SpideyGeometry
	
	d2h: (d) ->
		return d.toString(16)

	h2d: (h) ->
		return parseInt(h,16)

	zeropad: (n, width, z) ->
		z = z || '0'
		n = n + ''
		return if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

	execSpideyCmd: (cmdParams) ->
		# console.log "Sending " + cmdParams 
		$.ajax cmdParams,
			type: "GET"
			dataType: "text"
			success: (data, textStatus, jqXHR) =>
				return
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)

	sendLedCmd: (ledChainIdx, ledclr) ->
		clrStr = if ledclr is "green" then "00ff00" else "ff0000"
		@ipCmdBuf += "000802" + @zeropad(@d2h(ledChainIdx), 4) + "0001" + clrStr
		if @debugCanvas?
			led = @spideyGeometry.leds[ledChainIdx]
			@debugCanvas.fillStyle = ledclr
			@debugCanvas.fillRect(led.x, led.y, 3, 3)
		return

	preShowAll: () ->
		@ipCmdBuf = ""
		if @debugCanvas
			@debugCanvas.clearRect(0, 0, 500, 1000);
			for link in @spideyGeometry.links 
				@debugCanvas.beginPath();
				@debugCanvas.moveTo(link.xSource, link.ySource);
				@debugCanvas.lineTo(link.xTarget, link.yTarget);
				@debugCanvas.stroke();

	showAll: () ->
		# @ledsSel.attr("fill", (d) -> return d.clr)
		@ipCmdBuf = "0000000101" + @ipCmdBuf
		@execSpideyCmd("http://macallan:5078/rawcmd/" + @ipCmdBuf)
		return

	setNodeColour: (nodeIdx, disp, colour) ->
		node = @spideyGeometry.nodes[nodeIdx]
		for nodeLed in node.ledIdxs
			@sendLedCmd(nodeLed, colour)
		return

	setLinkColour: (nodeIdx, nodeLinkIdx, linkStep, disp, colour) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		for edge in link.padEdges
			if linkStep < edge.ledIdxs.length
				ledIdx = edge.ledIdxs[linkStep]
				@sendLedCmd(ledIdx, colour)
		return

	getNodeXY: (nodeIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		return { x: node.x, y: node.y }

	getLinkAngle: (nodeIdx, nodeLinkIdx) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		if not link?
			debugger
		return link.linkAngle

	getLinkLedXY: (nodeIdx, nodeLinkIdx, linkStep) ->
		node = @spideyGeometry.nodes[nodeIdx]
		linkIdx = node.linkIdxs[nodeLinkIdx]
		link = @spideyGeometry.links[linkIdx]
		ledIdx = link.padEdges[0].ledIdxs[linkStep]
		led = @spideyGeometry.leds[ledIdx]
		if not led?
			debugger
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
		return link.target

