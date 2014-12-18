// Generated by CoffeeScript 1.8.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.DisplayManager = (function() {
    DisplayManager.prototype.ledUISize = 3;

    DisplayManager.prototype.scriptObj = window;

    DisplayManager.prototype.registeredEvents = [];

    DisplayManager.prototype.MAX_COLOUR_SEQ_LEN = 250;

    DisplayManager.prototype.MAX_MSG_LEN_IN_HEXCHARS = 6000;

    function DisplayManager() {
      this.spideyDrawFunction = __bind(this.spideyDrawFunction, this);
      $("#spideyGeom").appendTo(".spideySvgImg");
      $("#spideyGeom").show();
      this.loadSpideyGeom();
      return;
    }

    DisplayManager.prototype.stop = function() {
      this.d3TimerStop = true;
      this.unregisterEvents();
    };

    DisplayManager.prototype.start = function() {
      this.d3TimerStop = false;
      d3.timer(this.spideyDrawFunction);
    };

    DisplayManager.prototype.showSpideyLeds = function() {
      this.ledsSel = this.d3PadsSvg.selectAll("g.led").data(this.spideyGeom.leds).enter().append("g").attr("class", "led").append("circle").attr("cx", function(d) {
        return d.x;
      }).attr("cy", function(d) {
        return d.y;
      }).attr("r", this.ledUISize).attr("fill", function(d, i) {
        return d.colour;
      });
    };

    DisplayManager.prototype.loadSpideyGeom = function() {
      var jqXHR;
      jqXHR = $.getJSON("/SpideyGeometry.json", (function(_this) {
        return function(data) {
          var led, _i, _j, _len, _len1, _ref, _ref1;
          _this.spideyGeom = data;
          console.log("LoadedSpideyGeom");
          _ref = _this.spideyGeom.leds;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            led = _ref[_i];
            led.colour = "#000000";
          }
          _this.d3PadsSvg = d3.select(".spideySvgImg svg");
          _this.padOutlines = _this.d3PadsSvg.selectAll("path");
          _this.showSpideyLeds();
          _this.scriptObj.LEDS = _this.spideyGeom.leds;
          _ref1 = _this.scriptObj.LEDS;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            led = _ref1[_j];
            led.dist = function(pt) {
              return window.dist(pt, this);
            };
          }
          _this.scriptObj.LEDS.closest = function(pt) {
            var curClosest, curMinDist, thisDist, _k, _len2;
            curClosest = null;
            curMinDist = 1000000;
            for (_k = 0, _len2 = this.length; _k < _len2; _k++) {
              led = this[_k];
              thisDist = led.dist(pt);
              if (curMinDist > thisDist) {
                curMinDist = thisDist;
                curClosest = led;
              }
            }
            return curClosest;
          };
          _this.scriptObj.PADS = _this.spideyGeom.pads;
        };
      })(this));
    };

    DisplayManager.prototype.spideyDrawFunction = function() {
      var e;
      if (this.d3TimerStop) {
        return true;
      }
      try {
        draw();
      } catch (_error) {
        e = _error;
        console.log("Error in draw() " + e);
        debugger;
      }
      return false;
    };

    DisplayManager.prototype.show = function() {
      this.ledsSel.attr("fill", function(d) {
        return d.colour;
      });
      this.sendLedsDataToSpidey();
    };

    DisplayManager.prototype.unregisterEvents = function() {
      var ev, _i, _len, _ref;
      _ref = this.registeredEvents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ev = _ref[_i];
        $(ev.cssSelector).unbind(ev.eventName);
      }
      this.registeredEvents = [];
    };

    DisplayManager.prototype.registerEvent = function(eventName, eventHandler) {
      var ev, retVal, selector;
      ev = {};
      ev.cssSelector = "#spideyWall";
      ev.eventName = eventName;
      ev.eventHandler = eventHandler;
      this.registeredEvents.push(ev);
      selector = $(ev.cssSelector);
      retVal = selector.bind(ev.eventName, ev, this.registeredEventHandler);
    };

    DisplayManager.prototype.registeredEventHandler = function(event) {
      var offset;
      offset = $(event.data.cssSelector).offset();
      event.x = event.clientX - offset.left;
      event.y = event.clientY - offset.top;
      return event.data.eventHandler(event);
    };

    DisplayManager.prototype.sendLedsDataToSpidey = function() {
      var cmdMsgs, colourSeqs, curMsgIdx, curSeqLen, firstInSeq, lastLedColour, ledIdx, msg, msgBody, seq, thisLedColour, _i, _j, _k, _len, _len1, _ref;
      lastLedColour = "";
      firstInSeq = -1;
      curSeqLen = 0;
      colourSeqs = [];
      for (ledIdx = _i = 0, _ref = this.spideyGeom.leds.length; 0 <= _ref ? _i <= _ref : _i >= _ref; ledIdx = 0 <= _ref ? ++_i : --_i) {
        thisLedColour = ledIdx < this.spideyGeom.leds.length ? this.colourToRgbStr(this.spideyGeom.leds[ledIdx].colour) : "TERMINAL";
        if (lastLedColour === thisLedColour) {
          curSeqLen++;
        } else {
          if (curSeqLen > 7) {
            colourSeqs.push({
              type: "seq",
              start: firstInSeq,
              len: curSeqLen,
              colourStr: lastLedColour
            });
          } else if (firstInSeq !== -1) {
            if ((colourSeqs.length === 0) || (colourSeqs[colourSeqs.length - 1].type === "seq")) {
              colourSeqs.push({
                type: "raw",
                start: firstInSeq,
                len: 1,
                colours: [lastLedColour]
              });
            } else {
              if (colourSeqs[colourSeqs.length - 1].colours.length < this.MAX_COLOUR_SEQ_LEN) {
                colourSeqs[colourSeqs.length - 1].colours.push(lastLedColour);
                colourSeqs[colourSeqs.length - 1].len++;
              } else {
                colourSeqs.push({
                  type: "raw",
                  start: firstInSeq,
                  len: 1,
                  colours: [lastLedColour]
                });
              }
            }
          }
          curSeqLen = 0;
          firstInSeq = ledIdx;
          lastLedColour = thisLedColour;
        }
      }
      cmdMsgs = [];
      cmdMsgs.push(this.cmdPreamble());
      curMsgIdx = 0;
      for (_j = 0, _len = colourSeqs.length; _j < _len; _j++) {
        seq = colourSeqs[_j];
        msgBody = this.cmdSequence(seq);
        if (cmdMsgs[curMsgIdx].length + msgBody.length > this.MAX_MSG_LEN_IN_HEXCHARS) {
          cmdMsgs[curMsgIdx] += this.cmdPostamble();
          curMsgIdx++;
          cmdMsgs.push(this.cmdPreamble());
        }
        cmdMsgs[curMsgIdx] += msgBody;
      }
      cmdMsgs[curMsgIdx] += this.cmdPostamble();
      for (_k = 0, _len1 = cmdMsgs.length; _k < _len1; _k++) {
        msg = cmdMsgs[_k];
        $.get(msg, function(data) {});
      }
    };

    DisplayManager.prototype.cmdPreamble = function() {
      return "/rawcmd/0000";
    };

    DisplayManager.prototype.cmdSequence = function(seq) {
      var cmdLen, cmdStr, colr, rawFillCmd, seqFillCmd, _i, _len, _ref;
      if (seq.type === "seq") {
        seqFillCmd = "02";
        cmdLen = 8;
        cmdStr = this.toHex(cmdLen, 4) + seqFillCmd;
        cmdStr += this.toHex(seq.start, 4) + this.toHex(seq.len, 4);
        cmdStr += seq.colourStr;
      } else {
        rawFillCmd = "05";
        cmdLen = seq.len * 3 + 5;
        cmdStr = this.toHex(cmdLen, 4) + rawFillCmd;
        cmdStr += this.toHex(seq.start, 4) + this.toHex(seq.len, 4);
        _ref = seq.colours;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          colr = _ref[_i];
          cmdStr += colr;
        }
      }
      return cmdStr;
    };

    DisplayManager.prototype.cmdPostamble = function() {
      return "";
    };

    DisplayManager.prototype.colourToRgbStr = function(colourStr) {
      return hexStringNoHash(getRgb(colourStr));
    };

    DisplayManager.prototype.toHex = function(val, digits) {
      return ("00000000" + val.toString(16)).slice(-digits);
    };

    return DisplayManager;

  })();

}).call(this);
