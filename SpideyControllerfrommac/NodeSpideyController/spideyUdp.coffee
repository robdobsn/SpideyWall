dgram = require('dgram')

# Spidey wall UDP connection handler
class @SpideyUDP
	serverReady: false

	constructor: (@spidey_UDP_IP, @spidey_udp_port) ->
		@server = dgram.createSocket("udp4")

		@server.on "error", (err) =>
			console.log "server error:\n" + err.stack
			@server.close()
			return

		@server.on "message", (msg, rinfo) =>
			console.log "server got: " + msg + " from " + rinfo.address + ":" + rinfo.port
			return

		@server.on "listening", =>
			address = @server.address()
			console.log "server listening " + address.address + ":" + address.port
			@serverReady = true

		@server.bind(@spidey_udp_port)


	execCmd: (cmdStr) ->
		cmdmsg = new Buffer(cmdStr, 'hex')

		console.log "Sending len " + cmdmsg.length

		@server.send cmdmsg, 0, cmdmsg.length, @spidey_udp_port, @spidey_UDP_IP, (err, bytes) ->
			if err
				console.log "UDP send error = " + err
				throw err
			else
				console.log "UDP sent " + bytes + " bytes"
		return

