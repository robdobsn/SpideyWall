class @DisplayManager
	
	ledUISize: 3

	constructor: ->
		$("#spideyGeom").appendTo(".spideySvgImg")
		$("#spideyGeom").show()
		@loadSpideyGeom()

	stop: ->
		@d3TimerStop = true

	start: ->
		@d3TimerStop = false
		d3.timer(spideyDrawFunction)

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

	loadSpideyGeom: ->
		jqXHR = $.getJSON "/SpideyGeometry.json", (data) =>
			@spideyGeom = data
			console.log "LoadedSpideyGeom"
			for led in @spideyGeom.leds
				led.colour = "#DCDCDC"
			@d3PadsSvg = d3.select(".spideySvgImg svg");
			@padOutlines = @d3PadsSvg.selectAll("path");
			@showSpideyLeds()
			@LEDS = @spideyGeom.leds
			for led in @LEDS
				led.dist = (pt) ->
					@dist(pt, this)
			@LEDS.closest = (pt) ->
				curClosest = null
				curMinDist = 1000000
				for led in this
					thisDist = led.dist(pt)
					if curMinDist > thisDist
						curMinDist = thisDist
						curClosest = led
				return curClosest

	dist: (pt1, pt2) ->
		return Math.sqrt(Math.pow(pt1.x - pt2.x, 2) + Math.pow(pt1.y - pt2.y, 2))

	spideyDrawFunction: ->
		if @d3TimerStop
			return true
		draw()
		return false

	show: ->
		@spideyDrawing.ledsSel.attr("fill", (d) -> return d.colour)

	random: (min, max) ->
		if max?
			return Math.floor(Math.random() * (max - min)) + min
		max = min
		min = 0
		return Math.floor(Math.random() * (max - min)) + min

	rgbColour = (r,g,b) ->
		return "rgb(" + r + "," + g + "," + b + ")"


