// Generated by CoffeeScript 1.8.0
var SpideyApp;

SpideyApp = (function() {
  function SpideyApp() {
    this.spideyWallIP = "192.168.0.227";
    this.spideyWall = new SpideyWall();
    return;
  }

  SpideyApp.prototype.go = function() {
    var spideyPacMan;
    this.spideyAppUI = new SpideyAppUI();
    this.spideyAppUI.init(this.spideyWall);
    spideyPacMan = new SpideyGame_PacMan(this, this.spideyWall, this.spideyAppUI);
    spideyPacMan.go();
    this.spideyAppUI.showGameUI(true);
  };

  SpideyApp.prototype.configTabNameClick = function() {
    var tabName;
    tabName = LocalStorage.get("DeviceConfigName");
    if (tabName == null) {
      tabName = "";
    }
    $("#tabnamefield").val(tabName);
    $("#tabnameok").unbind("click");
    $("#tabnameok").click(function() {
      LocalStorage.set("DeviceConfigName", $("#tabnamefield").val());
      return $("#tabnameform").hide();
    });
    $("#tabnameform").show();
  };

  return SpideyApp;

})();

$(document).bind("mobileinit", function() {
  $.mobile.allowCrossDomainPages = true;
  return $.support.cors = true;
});

$(document).ready(function() {
  var spideyApp;
  spideyApp = new SpideyApp();
  return spideyApp.go();
});