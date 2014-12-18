class @ScriptManager

	constructor: (@displayManager) ->
		@init()

	init: ->
		@editor = ace.edit("editor")
		@editor.setTheme("ace/theme/chrome")
		@editor.getSession().setMode("ace/mode/javascript")
		@addButtons()
		@showScriptList()
		return

	editScript: (scriptId) =>
		console.log "edit script " + scriptId
		@selectScript (scriptId)
		return

	deleteScript: (scriptId) =>
		console.log "delete script " + scriptId
		if not confirm("Delete script?")
			return
		$.ajax "/scripts/" + scriptId , 
			type: "DELETE"
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "Delete script by id AJAX Error: #{textStatus}"
			success: (data, textStatus, jqXHR) =>
				console.log  "Delete script by id successful AJAX call: #{data.ok}"
				console.log "script = " + scriptId
				@showScriptList()
		return

	newScript: =>
		@showScript("New Script", "")
		return

	saveScript: =>
		code = @editor.getSession().getValue()
		console.log btoa(code)
		scriptName = $("input[name=script-name]").val().trim()
		newScript =
			isUpdate: @scriptAtStart.name is scriptName
			name: scriptName
			code: btoa(code)
		jqXHR = $.ajax "/scripts", 
			type: "POST"
			data: JSON.stringify(newScript)
			dataType: "json"
			contentType: "application/json"
			error: (jqXHR, textStatus, errorThrown) =>
				console.log "AJAX Error: #{textStatus}"
				$(".spideyStatus").text textStatus
			success: (data, textStatus, jqXHR) =>
				console.log  "Successful AJAX call: #{data.ok}"
				if data.ok
					@showScriptList()
				else
					$(".spideyStatus").text if data.error is "nameexists" then "Script name already exists" else if "nameisblank" then "Script name can't be blank" else data.error
		return

	runScript: (event, scriptId) =>
		if scriptId?
			$.ajax "/scripts/" + scriptId , 
				type: "GET"
				error: (jqXHR, textStatus, errorThrown) =>
					console.log "Get to run script by id AJAX Error: #{textStatus}"
				success: (data, textStatus, jqXHR) =>
					console.log  "Get to run script by id successful AJAX call: #{data.name}"
					# console.log "script = " + scriptId
					# console.log "code = " + atob(data.code)
					@doScript atob(data.code)
		else
			code = @editor.getSession().getValue()
			@doScript(code)

	doScript: (code) ->
		window.draw = ->
			# empty
		window.clear("#000000")
		@displayManager.stop()
		eval code
		@displayManager.start()
		return

	stopScript: =>
		@displayManager.stop()
		return

	closeScript: =>
		if @scriptChanged
			if confirm('Discard changes?')
				@showScriptList()
			else
				return
		else
			@showScriptList()
		return

	addButtons: ->
		butInfos = [
			{ caption: "Run", clickfn: @runScript, class: "spidey-run-script"}
			{ caption: "Stop", clickfn: @stopScript, class: "spidey-stop-script"}
			{ caption: "Save", clickfn: @saveScript, class: "spidey-save-script"}
			{ caption: "Close", clickfn: @closeScript, class: "spidey-close-script"}
			{ caption: "New", clickfn: @newScript, class: "spidey-new-script"}
		]
		for butInfo in butInfos
			btnDef =
				"""
			        <a class="small round button #{butInfo.class}">#{butInfo.caption}</a>
				"""
			$(".script-button-row").append(btnDef)
			$(".#{butInfo.class}").on('click',butInfo.clickfn)
		return
 
	selectScript: (scriptId) ->
		$.ajax "/scripts/" + scriptId , 
			type: "GET"
			error: (jqXHR, textStatus, errorThrown) =>
				console.log "Get script by id AJAX Error: #{textStatus}"
			success: (data, textStatus, jqXHR) =>
				console.log  "Get script by id successful AJAX call: #{data.name}"
				# console.log "script = " + scriptId
				# console.log "code = " + atob(data.code)
				@showScript data.name, atob(data.code)
		return

	showScriptList: ->
		$(".spidey-new-script").show()
		$(".spidey-run-script").hide()
		$(".spidey-stop-script").show()
		$(".spidey-close-script").hide()
		$(".spidey-scripts").show()
		$("#editor").hide()
		$(".script-name").hide()
		$(".spidey-save-script").hide()
		@getAllSnippets()
		return

	showScript: (scriptName, scriptCode) ->
		$(".spidey-new-script").hide()
		$(".spidey-run-script").show()
		$(".spidey-stop-script").show()
		$(".spidey-close-script").show()
		$(".spidey-scripts").hide()
		$("#editor").show()
		$(".script-name").show()
		$(".script-name").empty().append('<input type="text" name="script-name"/>')
		$("input[name=script-name]").val scriptName
		@editor.getSession().setValue scriptCode
		@scriptAtStart = 
			name: scriptName
			code: scriptCode
		$(".spidey-save-script").show()
		@scriptChanged = false
		@editor.on "change", =>
			@scriptChanged = true
		return

	getAllSnippets: () ->
		jqXHR = $.getJSON "/scripts", (data) =>
			items = []
			$.each data, (idx, script) ->
				items.push """
					<tr>
					<td class="script-title">#{script.name}</td>
					<td><a class="small button" id="edit-script-#{idx}">Edit</a></td>
					<td><a class="small button" id="delete-script-#{idx}">Del</a></td>
					<td><a class="small button" id="run-script-#{idx}">Run</a></td>
					</tr>
					"""
				return
			$(".scripts-list").empty()
			$("<tbody/>",
				class: "script-list-body"
				html: items.join("")
			).appendTo ".scripts-list"
			$.each data, (idx, script) =>
				$("#edit-script-#{idx}").on 'click', =>
					@editScript(script._id)
					return
				$("#delete-script-#{idx}").on 'click', =>
					@deleteScript(script._id)
					return
				$("#run-script-#{idx}").on 'click', =>
					@runScript(null, script._id)
					return
			return
		jqXHR.fail ( jqxhr, textStatus, error ) =>
			err = textStatus + ", " + error
			console.log "Request Failed: " + err
			return
		jqXHR.always =>
			return
		return
