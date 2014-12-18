class @DisplayManager
	
	ledUISize: 3
	scriptObj: window
	registeredEvents: []
	MAX_COLOUR_SEQ_LEN: 250
	MAX_MSG_LEN_IN_HEXCHARS: 6000

	constructor: ->
		$("#spideyGeom").appendTo(".spideySvgImg")
		$("#spideyGeom").show()
		@loadSpideyGeom()
		return

	stop: ->
		@d3TimerStop = true
		@unregisterEvents()
		return

	start: ->
		@d3TimerStop = false
		d3.timer(@spideyDrawFunction)
		return

	showSpideyLeds: ->
		@ledsSel = @d3PadsSvg.selectAll("g.led")
			.data(@spideyGeom.leds)
			.enter()
			.append("g")
		 	.attr("class", "led")
			.append("circle")
		 	.attr("cx", (d) -> return d.x )
		 	.attr("cy", (d) -> return d.y )
		 	.attr("r", @ledUISize)
		 	.attr("fill", (d,i) -> return d.colour)
		return

	loadSpideyGeom: ->
		jqXHR = $.getJSON "/SpideyGeometry.json", (data) =>
			@spideyGeom = data
			console.log "LoadedSpideyGeom"
			for led in @spideyGeom.leds
				led.colour = "#000000"
			@d3PadsSvg = d3.select(".spideySvgImg svg");
			@padOutlines = @d3PadsSvg.selectAll("path");
			@showSpideyLeds()
			# LEDS
			@scriptObj.LEDS = @spideyGeom.leds
			for led in @scriptObj.LEDS
				led.dist = (pt) ->
					window.dist(pt, this)
			@scriptObj.LEDS.closest = (pt) ->
				curClosest = null
				curMinDist = 1000000
				for led in this
					thisDist = led.dist(pt)
					if curMinDist > thisDist
						curMinDist = thisDist
						curClosest = led
				return curClosest
			@scriptObj.PADS = @spideyGeom.pads
			return
		return


	spideyDrawFunction: =>
		if @d3TimerStop
			return true
		try
			draw()
		catch e
			console.log "Error in draw() " + e
			debugger
		return false

	show: ->
		@ledsSel.attr("fill", (d) -> return d.colour)
		# Send to spidey wall
		@sendLedsDataToSpidey()
		return

	unregisterEvents: ->
		for ev in @registeredEvents
			$(ev.cssSelector).unbind(ev.eventName)
		@registeredEvents = []
		return

	registerEvent: (eventName, eventHandler) ->
		ev = {}
		ev.cssSelector = "#spideyWall"
		ev.eventName = eventName
		ev.eventHandler = eventHandler
		@registeredEvents.push ev
		selector = $(ev.cssSelector)
		retVal = selector.bind(ev.eventName, ev, @registeredEventHandler)
		return

	registeredEventHandler: (event) ->
		offset = $(event.data.cssSelector).offset()
		event.x = event.clientX - offset.left
		event.y = event.clientY - offset.top
		event.data.eventHandler(event)

	sendLedsDataToSpidey: () ->
		# Find runs of the same value
		lastLedColour = ""
		firstInSeq = -1
		curSeqLen = 0
		colourSeqs = []
		for ledIdx in [0..@spideyGeom.leds.length]   # intentionally inclusive
			thisLedColour = if (ledIdx < @spideyGeom.leds.length) then @colourToRgbStr(@spideyGeom.leds[ledIdx].colour) else "TERMINAL"
			if lastLedColour is thisLedColour
				curSeqLen++
			else
				if curSeqLen > 7
					colourSeqs.push
						type: "seq"
						start: firstInSeq
						len: curSeqLen
						colourStr: lastLedColour
				else if firstInSeq isnt -1
					if (colourSeqs.length is 0) or (colourSeqs[colourSeqs.length-1].type is "seq")
						colourSeqs.push
							type: "raw"
							start: firstInSeq
							len: 1
							colours: [ lastLedColour ]
					else
						if colourSeqs[colourSeqs.length-1].colours.length < @MAX_COLOUR_SEQ_LEN
							colourSeqs[colourSeqs.length-1].colours.push lastLedColour
							colourSeqs[colourSeqs.length-1].len++
						else
							colourSeqs.push
								type: "raw"
								start: firstInSeq
								len: 1
								colours: [ lastLedColour ]
				curSeqLen = 0
				firstInSeq = ledIdx
				lastLedColour = thisLedColour

		cmdMsgs = []
		cmdMsgs.push @cmdPreamble()
		curMsgIdx = 0
		for seq in colourSeqs
			# console.log "Seq type " + seq.type + " start " + seq.start + " len " + seq.len + " info " + (if seq.type is "raw" then seq.colours.length else seq.colourStr)
			msgBody = @cmdSequence(seq)
			if cmdMsgs[curMsgIdx].length + msgBody.length > @MAX_MSG_LEN_IN_HEXCHARS
				cmdMsgs[curMsgIdx] += @cmdPostamble()
				curMsgIdx++
				cmdMsgs.push @cmdPreamble()
			cmdMsgs[curMsgIdx] += msgBody
		cmdMsgs[curMsgIdx] += @cmdPostamble()

		# Send messages
		for msg in cmdMsgs
			$.get msg, ( data ) ->
				# console.log "Sent len = " + msg.length


		# # Go through all leds and generate message(s)
		# cmdMsg = @cmdPreamble()
		# curSeqIdx = 0
		# ledIdx = 0
		# while ledIdx < @spideyGeom.leds.length
		# 	if curSeqIdx < colourSeqs.length
		# 		if colourSeqs[curSeqIdx].start == ledIdx
		# 			cmdMsg += @cmdSequence(colourSeqs[curSeqIdx])
		# 			ledIdx += colourSeqs[curSeqIdx].len
		# 			continue
		# 	cmdMsg+=



		# numLedsPerCall = 850
		# rawFillCmd = "05"
		# numLedsToSend = 0
		# for led, ledIdx in @spideyGeom.leds
		# 	if ledIdx % numLedsPerCall is 0
		# 		numLeft = (@spideyGeom.leds.length - ledIdx)
		# 		numLedsToSend = if numLeft < numLedsPerCall then numLeft else numLedsPerCall
		# 		cmdLen = numLedsToSend * 3 + 5
		# 		sCmd = "/rawcmd/0000"
		# 		sCmd += @toHex(cmdLen,4) + rawFillCmd
		# 		sCmd += @toHex(ledIdx,4) + @toHex(numLedsToSend,4)
		# 	sCmd += @colourToRgbStr(led.colour)
		# 	if ledIdx % numLedsPerCall is numLedsToSend - 1
		# 		$.get sCmd, ( data ) ->
		# 			console.log "sent " + sCmd
		return

	cmdPreamble: ->
		return "/rawcmd/0000"

	cmdSequence: (seq) ->
		if seq.type is "seq"
			seqFillCmd = "02"
			cmdLen = 8
			cmdStr = @toHex(cmdLen,4) + seqFillCmd
			cmdStr += @toHex(seq.start,4) + @toHex(seq.len,4)
			cmdStr += seq.colourStr
		else
			rawFillCmd = "05"
			cmdLen = seq.len * 3 + 5
			cmdStr = @toHex(cmdLen,4) + rawFillCmd
			cmdStr += @toHex(seq.start,4) + @toHex(seq.len,4)
			for colr in seq.colours
				cmdStr += colr
		return cmdStr

	cmdPostamble: () ->
		return ""

	colourToRgbStr: (colourStr) ->
		return hexStringNoHash(getRgb(colourStr))

	toHex: (val, digits) ->
		 return ("00000000" + val.toString(16)).slice(-digits);
