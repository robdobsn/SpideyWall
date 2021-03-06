// Generated by CoffeeScript 1.8.0
(function() {
  window.show = function() {
    return window.displayManager.show();
  };

  window.random = function(min, max) {
    if (max != null) {
      return Math.floor(Math.random() * (max - min)) + min;
    }
    max = min;
    min = 0;
    return Math.floor(Math.random() * (max - min)) + min;
  };

  window.rgb = function(r, g, b) {
    return "rgb(" + r + "," + g + "," + b + ")";
  };

  window.dist = function(pt1, pt2) {
    return Math.sqrt(Math.pow(pt1.x - pt2.x, 2) + Math.pow(pt1.y - pt2.y, 2));
  };

  window.catchEvent = function(eventName, eventHandler) {
    return window.displayManager.registerEvent(eventName, eventHandler);
  };

  window.clear = function(colour) {
    var led, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = LEDS.length; _i < _len; _i++) {
      led = LEDS[_i];
      _results.push(led.colour = colour);
    }
    return _results;
  };

}).call(this);
