class SpideyWall
	
	d2h: (d) ->
		return d.toString(16)

	h2d: (h) ->
		return parseInt(h,16)

	zeropad: (n, width, z) ->
		z = z || '0'
		n = n + ''
		return if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

	execSpideyCmd: (cmdParams) ->
		console.log "Sending " + cmdParams 
		$.ajax cmdParams,
			type: "GET"
			dataType: "text"
			success: (data, textStatus, jqXHR) =>
				return
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)

	sendLedCmd: (ledChainIdx, ledclr) ->
		clrStr = if ledclr is "white" then "000000" else "800000"
		if ledclr isnt "white"
			@ipCmdBuf += "000802" + @zeropad(@d2h(ledChainIdx), 4) + "0001" + clrStr
		return

	setNodeColour: (nodeIdx, disp, colour) ->
		node = @spideyGraph.nodeList[nodeIdx]
		dbg = ""
		for nodeLed in node.leds
			if disp
				nodeLed.led.clr = colour
			else
				nodeLed.led.clr = "white"
			@sendLedCmd(nodeLed.led.chainIdx, nodeLed.led.clr)
			dbg += "P" + nodeLed.padIdx + " X" + nodeLed.ledIdx + " C" + nodeLed.led.chainIdx + ", "
		$('#DebugInfo2').text(dbg)
		return

	setLinkColour: (nodeIdx, linkIdx, linkStep, disp, colour) ->
		node = @spideyGraph.nodeList[nodeIdx]
		link = node.edgesTo[linkIdx]
		dbg = ""
		if linkStep < link.edgeList.length
			for edgeLeds in link.edgeList[linkStep]
				led = edgeLeds.led
				dbg += "P" + led.padIdx + " X" + led.ledIdx + " C" + led.chainIdx + ", "
				if disp
					led.clr = colour
				else
					led.clr = "white"
				@sendLedCmd(led.chainIdx, led.clr)
		else
			dbg = "ListLenErr"
		$('#DebugInfo2').text(dbg)
		return

	getNodeXY: (nodeIdx) ->
		return @spideyGraph.nodeList[nodeIdx].CofG.pt

	getLinkLedXY: (nodeIdx, linkIdx, linkStep) ->
		return @spideyGraph.nodeList[nodeIdx].edgesTo[linkIdx].edgeList[linkStep][0].led.pt

	getNumLinks: (nodeIdx) ->
		return @spideyGraph.nodeList[nodeIdx].edgesTo.length

	getLinkLength: (nodeIdx, linkIdx) ->
		return @spideyGraph.nodeList[nodeIdx].edgesTo[linkIdx].edgeList.length

	getLinkTarget: (nodeIdx, linkIdx) ->
		return @spideyGraph.nodeList[nodeIdx].edgesTo[linkIdx].toNodeIdx

	preShowAll: () ->
		@ipCmdBuf = ""

	showAll: () ->
		# @ledsSel.attr("fill", (d) -> return d.clr)
		@ipCmdBuf = "0000000101" + @ipCmdBuf
		@execSpideyCmd("http://macallan:5078/rawcmd/" + @ipCmdBuf)
		return
