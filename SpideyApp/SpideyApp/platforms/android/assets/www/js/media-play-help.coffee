class MediaPlayHelper
    constructor: (@soundsDict) ->
        @soundsLoaded = {}

    getPhoneGapPath: ->
        path = window.location.pathname
        path = path.substr( path, path.length - 10 )
        if path.substr(-1) isnt '/'
            path = path + '/'
        return 'file://' + path

    play: (soundName) ->
        if soundName of @soundsDict
            bTryAudio = false
            if window.plugins and window.plugins.LowLatencyAudio
                try
                    if soundName not of @soundsLoaded
                        window.plugins.LowLatencyAudio.preloadAudio(soundName, @soundsDict[soundName], 1, @onSuccess, @onError)
                        @soundsLoaded[soundName] = true
                    window.plugins.LowLatencyAudio.play(soundName, @onSuccess, @onError)
                catch e
                    bTryAudio = true
            else
                bTryAudio = true
            if bTryAudio
                try
                    snd = new Audio(@soundsDict[soundName])
                    snd.play()
                catch e
                    console.log("LowLatencyAudio and Audio both failed")

    onSuccess: (result) ->
        console.log("LLAUDIO result = " + result )

    onError: (error) ->
        console.log("LLAUDIO error = " + error )
