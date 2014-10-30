
getSnippets = () ->
	jqXHR = $.getJSON "scripts/all.json", (data) ->
		items = []
		window.spideyScripts = data
		$.each data.scripts, (idx, script) ->
			items.push """
				<div class="post-frame">
					<a onclick="selectScript(#{idx})" class="button" id="#{idx}">#{script.name}</a>
				</div>
				"""
			return

		$("<ul/>", 
			class: "my-new-list"		
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

selectScript = (scriptIdx) ->
	console.log "script = " + scriptIdx
	console.log "code = " + window.spideyScripts.scripts[scriptIdx].code