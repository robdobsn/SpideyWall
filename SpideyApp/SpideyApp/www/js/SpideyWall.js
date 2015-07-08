// Generated by CoffeeScript 1.8.0
var SpideyWall;

SpideyWall = (function() {
  function SpideyWall() {
    this.spideyGeometry = window.SpideyGeometry;
  }

  SpideyWall.prototype.setCanvas = function(canvas) {
    this.canvas = canvas;
  };

  SpideyWall.prototype.d2h = function(d) {
    return d.toString(16);
  };

  SpideyWall.prototype.h2d = function(h) {
    return parseInt(h, 16);
  };

  SpideyWall.prototype.zeropad = function(n, width, z) {
    z = z || '0';
    n = n + '';
    if (n.length >= width) {
      return n;
    } else {
      return new Array(width - n.length + 1).join(z) + n;
    }
  };

  SpideyWall.prototype.execSpideyCmd = function(cmdParams) {
    return $.ajax(cmdParams, {
      type: "GET",
      dataType: "text",
      success: (function(_this) {
        return function(data, textStatus, jqXHR) {};
      })(this),
      error: (function(_this) {
        return function(jqXHR, textStatus, errorThrown) {
          return console.error("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams);
        };
      })(this)
    });
  };

  SpideyWall.prototype.sendLedCmd = function(ledChainIdx, ledclr) {
    var clrStr, led;
    clrStr = ledclr === "green" ? "00ff00" : "ff0000";
    this.ipCmdBuf += "000802" + this.zeropad(this.d2h(ledChainIdx), 4) + "0001" + clrStr;
    if (this.canvas != null) {
      led = this.spideyGeometry.leds[ledChainIdx];
      this.canvas.fillStyle = ledclr;
      this.canvas.fillRect(led.x, led.y, 3, 3);
    }
  };

  SpideyWall.prototype.preShowAll = function() {
    var link, _i, _j, _len, _len1, _ref, _ref1, _results;
    this.ipCmdBuf = "";
    if (this.canvas) {
      this.canvas.fillStyle = "black";
      this.canvas.fillRect(0, 0, 500, 1000);
      this.canvas.lineWidth = 15;
      _ref = this.spideyGeometry.links;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        link = _ref[_i];
        this.canvas.beginPath();
        this.canvas.moveTo(link.xSource, link.ySource);
        this.canvas.lineTo(link.xTarget, link.yTarget);
        this.canvas.strokeStyle = "blue";
        this.canvas.stroke();
      }
      this.canvas.lineWidth = 10;
      _ref1 = this.spideyGeometry.links;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        link = _ref1[_j];
        this.canvas.beginPath();
        this.canvas.moveTo(link.xSource, link.ySource);
        this.canvas.lineTo(link.xTarget, link.yTarget);
        this.canvas.strokeStyle = "black";
        _results.push(this.canvas.stroke());
      }
      return _results;
    }
  };

  SpideyWall.prototype.showAll = function() {
    this.ipCmdBuf = "0000000101" + this.ipCmdBuf;
    this.execSpideyCmd("http://macallan:5078/rawcmd/" + this.ipCmdBuf);
  };

  SpideyWall.prototype.setNodeColour = function(nodeIdx, disp, colour) {
    var node, nodeLed, _i, _len, _ref;
    node = this.spideyGeometry.nodes[nodeIdx];
    _ref = node.ledIdxs;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      nodeLed = _ref[_i];
      this.sendLedCmd(nodeLed, colour);
    }
  };

  SpideyWall.prototype.setLinkColour = function(nodeIdx, nodeLinkIdx, linkStep, disp, colour) {
    var edge, ledIdx, link, linkIdx, node, _i, _len, _ref;
    node = this.spideyGeometry.nodes[nodeIdx];
    linkIdx = node.linkIdxs[nodeLinkIdx];
    link = this.spideyGeometry.links[linkIdx];
    _ref = link.padEdges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      edge = _ref[_i];
      if (linkStep < edge.ledIdxs.length) {
        ledIdx = edge.ledIdxs[linkStep];
        this.sendLedCmd(ledIdx, colour);
      }
    }
  };

  SpideyWall.prototype.getNodeXY = function(nodeIdx) {
    var node;
    node = this.spideyGeometry.nodes[nodeIdx];
    return {
      x: node.x,
      y: node.y
    };
  };

  SpideyWall.prototype.getLinkAngle = function(nodeIdx, nodeLinkIdx) {
    var link, linkIdx, node;
    node = this.spideyGeometry.nodes[nodeIdx];
    linkIdx = node.linkIdxs[nodeLinkIdx];
    link = this.spideyGeometry.links[linkIdx];
    if (link == null) {
      debugger;
    }
    return link.linkAngle;
  };

  SpideyWall.prototype.getLinkLedXY = function(nodeIdx, nodeLinkIdx, linkStep) {
    var led, ledIdx, link, linkIdx, node;
    node = this.spideyGeometry.nodes[nodeIdx];
    linkIdx = node.linkIdxs[nodeLinkIdx];
    link = this.spideyGeometry.links[linkIdx];
    ledIdx = link.padEdges[0].ledIdxs[linkStep];
    led = this.spideyGeometry.leds[ledIdx];
    if (led == null) {
      debugger;
    }
    return {
      x: led.x,
      y: led.y
    };
  };

  SpideyWall.prototype.getNumLinks = function(nodeIdx) {
    var node;
    node = this.spideyGeometry.nodes[nodeIdx];
    return node.linkIdxs.length;
  };

  SpideyWall.prototype.getLinkLength = function(nodeIdx, nodeLinkIdx) {
    var edgeLen, link, linkIdx, node, padEdge, _i, _len, _ref;
    node = this.spideyGeometry.nodes[nodeIdx];
    linkIdx = node.linkIdxs[nodeLinkIdx];
    link = this.spideyGeometry.links[linkIdx];
    edgeLen = 1000;
    _ref = link.padEdges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      padEdge = _ref[_i];
      if (edgeLen > padEdge.ledIdxs.length) {
        edgeLen = padEdge.ledIdxs.length;
      }
    }
    return edgeLen;
  };

  SpideyWall.prototype.getLinkTarget = function(nodeIdx, nodeLinkIdx) {
    var link, linkIdx, node;
    node = this.spideyGeometry.nodes[nodeIdx];
    linkIdx = node.linkIdxs[nodeLinkIdx];
    link = this.spideyGeometry.links[linkIdx];
    return link.target;
  };

  return SpideyWall;

})();
