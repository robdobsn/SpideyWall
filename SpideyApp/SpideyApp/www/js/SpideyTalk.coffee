# Communicate with the spidey wall

class SpideyTalk

	constructor: () ->
		@execHtmlCmd = "http://macallan:5078/rawcmd/"
		@enableExecHtml = false
	
	d2h: (d) ->
		return d.toString(16)

	h2d: (h) ->
		return parseInt(h,16)

	zeropad: (n, width, z) ->
		z = z || '0'
		n = n + ''
		return if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

	execSpideyCmd: (cmdParams) ->
		if @enableExecHtml
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
		if @canvas?
			led = @spideyGeometry.leds[ledChainIdx]
			@canvas.fillStyle = ledclr
			@canvas.fillRect(led.x, led.y, 10, 10)
		return

	preShowAll: () ->
		@ipCmdBuf = ""		

	showAll: () ->
		# @ledsSel.attr("fill", (d) -> return d.clr)
		@ipCmdBuf = "0000000101" + @ipCmdBuf
		@execSpideyCmd(@execHtmlCmd + @ipCmdBuf)
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