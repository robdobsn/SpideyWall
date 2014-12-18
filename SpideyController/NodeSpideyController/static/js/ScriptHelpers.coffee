window.show = ->
	window.displayManager.show()

window.random = (min, max) ->
	if max?
		return Math.floor(Math.random() * (max - min)) + min
	max = min
	min = 0
	return Math.floor(Math.random() * (max - min)) + min

window.rgb = (r,g,b) ->
	return "rgb(" + r + "," + g + "," + b + ")"

window.dist = (pt1, pt2) ->
	return Math.sqrt(Math.pow(pt1.x - pt2.x, 2) + Math.pow(pt1.y - pt2.y, 2))

window.catchEvent = (eventName, eventHandler) ->
	window.displayManager.registerEvent(eventName, eventHandler)

window.clear = (colour) ->
	for led in LEDS
		led.colour = colour

