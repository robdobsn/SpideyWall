# SpideyApp - the main app module

class SpideyApp

	constructor: ->
		# @spideyWallIP = "192.168.0.227"
		@spideyWall = new SpideyWall()
		return

	go: ->
		@spideyAppUI = new SpideyAppUI()
		@spideyAppUI.init(@spideyWall, @restartCallback)
		@spideyPacMan = new SpideyGame_PacMan(this, @spideyWall, @spideyAppUI)
		@spideyPacMan.go(false)
		return

	restartCallback: () =>
		@spideyAppUI.init(@spideyWall, @restartCallback)
		@spideyPacMan.go(true)
		return

	configTabNameClick: ->
		tabName = LocalStorage.get("DeviceConfigName")
		if not tabName?
			tabName = ""
		$("#tabnamefield").val(tabName)
		$("#tabnameok").unbind("click")
		$("#tabnameok").click ->
			LocalStorage.set("DeviceConfigName", $("#tabnamefield").val())
			$("#tabnameform").hide()
		$("#tabnameform").show()
		return

$(document).bind ("mobileinit"), ->
	# This isn't currently needed as the tablet now uses a local server
	$.mobile.allowCrossDomainPages = true
	$.support.cors = true
	return

$(document).ready ->
	spideyApp = new SpideyApp()
	spideyApp.go()
	return
	