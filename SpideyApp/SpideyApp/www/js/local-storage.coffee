class LocalStorage

	@get: (key) ->
		rslt = null
		if window.Storage and window.JSON
			item = localStorage.getItem(key)
			rslt = JSON.parse(item) if item
		return rslt

	@set: (key, value) ->
		if window.Storage and window.JSON
			localStorage.setItem(key, JSON.stringify(value))
			return true
		return false

