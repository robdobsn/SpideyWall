
getAllSnippets = () ->
	jqXHR = $.getJSON "/scripts", (data) ->
		items = []
		spideyScripts = data
		$.each data, (idx, script) ->
			items.push """
				<tr>
				<td class="script-title">#{script.name}</td>
				<td><a onclick="editScript('#{script._id}');" class="small button" id="edit-script-#{idx}">Edit</a></td>
				<td><a onclick="deleteScript('#{script._id}');" class="small button" id="delete-script-#{idx}">Del</a></td>
				</tr>
				"""
			return
		$(".scripts-list").empty()
		$("<tbody/>",
			class: "script-list-body"
			html: items.join("")
		).appendTo ".scripts-list"
		return
	jqXHR.fail ( jqxhr, textStatus, error ) ->
		err = textStatus + ", " + error
		console.log "Request Failed: " + err
		return
	jqXHR.always ->
		console.log "always"
		return
	return

editScript = (scriptId) ->
	selectScript (scriptId)

deleteScript = (scriptId) ->
	console.log "delete script " + scriptId
	if not confirm("Delete script?")
		return
	$.ajax "/scripts/" + scriptId , 
		type: "DELETE"
		error: (jqXHR, textStatus, errorThrown) ->
			console.log "Delete script by id AJAX Error: #{textStatus}"
		success: (data, textStatus, jqXHR) ->
			console.log  "Delete script by id successful AJAX call: #{data.ok}"
			console.log "script = " + scriptId
			showScriptList()
	return	

selectScript = (scriptId) ->
	$.ajax "/scripts/" + scriptId , 
		type: "GET"
		error: (jqXHR, textStatus, errorThrown) ->
			console.log "Get script by id AJAX Error: #{textStatus}"
		success: (data, textStatus, jqXHR) ->
			console.log  "Get script by id successful AJAX call: #{data.ok}"
			console.log "script = " + scriptId
			console.log "code = " + atob(data.code)
			spideyShowScript data.name, atob(data.code)
	return

initSpidey = ->
	window.editor = ace.edit("editor")
	window.editor.setTheme("ace/theme/chrome")
	window.editor.getSession().setMode("ace/mode/javascript")
	$("#spideyGeom").appendTo(".spideySvgImg")
	$("#spideyGeom").show()
	showScriptList()
	loadSpideyGeom()
	return

showSpideyLeds = ->
	window.spideyDrawing.ledsSel = window.spideyDrawing.d3PadsSvg.selectAll("g.led")
		.data(window.spideyGeom.leds)
		.enter()
		.append("g")
	 	.attr("class", "led")
		.append("circle")
	 	.attr("cx", (d) -> return d.x )
	 	.attr("cy", (d) -> return d.y )
	 	.attr("r", window.spideyDrawing.ledUISize)
	 	.attr("fill", (d,i) -> return d.colour)

loadSpideyGeom = ->
	jqXHR = $.getJSON "/SpideyGeometry.json", (data) ->
		window.spideyGeom = data
		console.log "LoadedSpideyGeom"
		for led in window.spideyGeom.leds
			led.colour = "#DCDCDC"
		window.spideyDrawing =
			ledUISize: 3
		window.spideyDrawing.d3PadsSvg = d3.select(".spideySvgImg svg");
		window.spideyDrawing.padOutlines = window.spideyDrawing.d3PadsSvg.selectAll("path");
		showSpideyLeds()
		window.LEDS = window.spideyGeom.leds
		for led in window.LEDS
			led.dist = (pt) ->
				window.dist(pt, this)
		window.LEDS.closest = (pt) ->
			curClosest = null
			curMinDist = 1000000
			for led in this
				thisDist = led.dist(pt)
				if curMinDist > thisDist
					curMinDist = thisDist
					curClosest = led
			return curClosest
		window.PADS = window.spideyGeom.pads

window.dist = (pt1, pt2) ->
	return Math.sqrt(Math.pow(pt1.x - pt2.x, 2) + Math.pow(pt1.y - pt2.y, 2))

showScriptList = ->
	$(".spidey-new-script").show()
	$(".spidey-run-script").hide()
	$(".spidey-stop-script").hide()
	$(".spidey-close-script").hide()
	$(".spidey-scripts").show()
	$("#editor").hide()
	$(".script-name").hide()
	$(".spidey-save-script").hide()
	getAllSnippets()
	return

spideyNewScript = ->
	spideyShowScript("New Script", "")

spideyShowScript = (scriptName, scriptCode) ->
	$(".spidey-new-script").hide()
	$(".spidey-run-script").show()
	$(".spidey-stop-script").show()
	$(".spidey-close-script").show()
	$(".spidey-scripts").hide()
	$("#editor").show()
	$(".script-name").show()
	$(".script-name").empty().append('<input type="text" name="script-name"/>')
	$("input[name=script-name]").val scriptName
	window.editor.getSession().setValue scriptCode
	window.spideyScriptAtStart = 
		name: scriptName
		code: scriptCode
	$(".spidey-save-script").show()
	window.spideyScriptChanged = false
	window.editor.on "change", ->
		window.spideyScriptChanged = true
	return

spideySaveScript = ->
	code = window.editor.getSession().getValue()
	console.log btoa(code)
	scriptName = $("input[name=script-name]").val().trim()
	newScript =
		isUpdate: window.spideyScriptAtStart.name is scriptName
		name: scriptName
		code: btoa(code)
	jqXHR = $.ajax "/scripts", 
		type: "POST"
		data: JSON.stringify(newScript)
		dataType: "json"
		contentType: "application/json"
		error: (jqXHR, textStatus, errorThrown) ->
			console.log "AJAX Error: #{textStatus}"
			$(".spideyStatus").text textStatus
		success: (data, textStatus, jqXHR) ->
			console.log  "Successful AJAX call: #{data.ok}"
			if data.ok
				showScriptList()
			else
				$(".spideyStatus").text if data.error is "nameexists" then "Script name already exists" else if "nameisblank" then "Script name can't be blank" else data.error
	return

spideyRunScript = ->
	code = window.editor.getSession().getValue()
	eval code
	window.d3TimerStop = false
	d3.timer(spideyDrawFunction)
	return

spideyStopScript = ->
	window.d3TimerStop = true
	return

spideyDrawFunction = ->
	if window.d3TimerStop
		return true
	try
		draw()
	catch e
		# empty
	
	return false

spideyCloseScript = ->
	if window.spideyScriptChanged
		if confirm('Discard changes?')
			showScriptList()
		else
			return
	else
		showScriptList()

show = ->
	window.spideyDrawing.ledsSel.attr("fill", (d) -> return d.colour)

random = (min, max) ->
	if max?
		return Math.floor(Math.random() * (max - min)) + min
	max = min
	min = 0
	return Math.floor(Math.random() * (max - min)) + min

rgbColour = (r,g,b) ->
	return "rgb(" + r + "," + g + "," + b + ")"


