class SpideyApp
    constructor: ->
        @spideyWallIP = "192.168.0.227"
        @mediaPlayHelper = new MediaPlayHelper(
            {
                click: "assets/click.mp3",
                ok: "assets/blip.mp3",
                fail: "assets/fail.mp3"
            })
        return

    go: ->
        # Basic body for DOM
        $("body").prepend """
            <div id="sqWrapper">
                <div id="gamebuttons">
                </div>
            </div>
            """
        # Handler for orientation change
        $(window).on 'orientationchange', =>
          @rebuildUI()
        # And resize event
        $(window).on 'resize', =>
          @rebuildUI()
        # Rebuild UI
        @rebuildUI()
        return

    upArrowClick: ->
        return

    rebuildUI: =>
        tb = new TileBasics("red", 1, 1, @upArrowClick, "", "Up", "all", "#gamebuttons", "gamebutton", "uparrow", true, @mediaPlayHelper)
        tb.setTierGroupIds(0,0)
        upArrowButton = new Tile(tb)
        upArrowButton.setTileIndex(0)
        upArrowButton.addToDoc()
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

$(document).ready ->
    spideyApp = new SpideyApp()
    spideyApp.go()
