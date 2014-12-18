// Generated by CoffeeScript 1.8.0
(function() {
  var IPADDR, PORT, TOTLEDS, cmdmsg, dgram, k, n, nextStep, sendMsg, server;

  dgram = require('dgram');

  PORT = 7;

  IPADDR = "192.168.0.227";

  TOTLEDS = 30;

  cmdmsg = new Buffer("01010b0200000001000000000000", 'hex');

  server = dgram.createSocket("udp4");

  k = 0;

  n = 0;

  server.on("error", function(err) {
    console.log("server error:\n" + err.stack);
    server.close();
  });

  server.on("message", function(msg, rinfo) {
    console.log("server got: " + msg + " from " + rinfo.address + ":" + rinfo.port);
  });

  server.on("listening", function() {
    var address;
    address = server.address();
    console.log("server listening " + address.address + ":" + address.port);
    sendMsg();
  });

  sendMsg = function() {
    cmdmsg[2] = 11;
    cmdmsg[4] = Math.floor(n / 256);
    cmdmsg[5] = Math.floor(n % 256);
    cmdmsg[7] = 1;
    cmdmsg[8] = 255;
    cmdmsg[11] = 255;
    console.log("Sending " + k + " len " + cmdmsg.length);
    server.send(cmdmsg, 0, cmdmsg.length, PORT, IPADDR, function(err, bytes) {
      if (err) {
        throw err;
      }
      console.log(err + " bytes " + bytes);
      return setTimeout(nextStep, 100);
    });
    console.log("here22");
  };

  nextStep = function() {
    n++;
    if (n >= TOTLEDS) {
      n = 0;
    }
    k++;
    if (k === 100) {
      server.close();
      return console.log("Done");
    } else {
      sendMsg();
      return console.log("Here");
    }
  };

  server.bind(PORT);

}).call(this);
