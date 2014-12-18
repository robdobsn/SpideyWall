dgram = require('dgram')

# Spidey wall UDP connection handler
class @SpideyUDP
	serverReady: false
	spideyCmds: []
	senderBusy: false
	seqCount: 0
	udpTimeout: null
	MAX_QUEUED_CMDS: 10

	constructor: (@spidey_UDP_IP, @spidey_udp_port) ->
		@server = dgram.createSocket("udp4")

		@server.on "error", (err) =>
			console.log "server error:\n" + err.stack
			@server.close()
			return

		@server.on "message", (msg, rinfo) =>
			console.log "server got: .." + msg + ".. from " + rinfo.address + ":" + rinfo.port
			if msg.toString().indexOf("OK") is 5
				clearTimeout(@udpTimeout)
				@senderBusy = false
				if @spideyCmds.length > 0
					# console.log "Sending next"
					@sendCmd(@spideyCmds.shift())
			return

		@server.on "listening", =>
			address = @server.address()
			console.log "server listening " + address.address + ":" + address.port
			@serverReady = true

		@server.bind(@spidey_udp_port)

	execCmd: (cmdStr) ->
		seqCmdStr = @toHex(@seqCount++,4) + cmdStr.slice(4)
		if @senderBusy
			if @spideyCmds.length < @MAX_QUEUED_CMDS
				@spideyCmds.push seqCmdStr
		else
			@sendCmd(seqCmdStr)

	timedOut: () =>
		console.log "Timedout"
		@senderBusy = false
		if @spideyCmds.length > 0
			console.log "Sending again after timeout"
			@sendCmd(@spideyCmds.shift())

	sendCmd: (cmdStr) ->
		@senderBusy = true
		@udpTimeout = setTimeout(@timedOut, 500)
		cmdmsg = new Buffer(cmdStr, 'hex')
		# console.log "Sending len " + cmdmsg.length
		@server.send cmdmsg, 0, cmdmsg.length, @spidey_udp_port, @spidey_UDP_IP, (err, bytes) =>
			if err
				console.log "UDP send error = " + err
				throw err
			else
				console.log "UDP sent " + bytes + " bytes"
		return

	toHex: (val, digits) ->
		 return ("00000000" + val.toString(16)).slice(-digits);