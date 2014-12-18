dgram = require('dgram')

# fromhex: (hexstr) ->
# 	for i in [0...hexstr.length/2]
# 		parseInt(hexstr[i..i+1],16)

PORT = 7
IPADDR = "192.168.0.227"
TOTLEDS = 30

cmdmsg = new Buffer("01010b0200000001000000000000", 'hex')
server = dgram.createSocket("udp4")
k = 0
n = 0

server.on "error", (err) ->
	console.log "server error:\n" + err.stack
	server.close()
	return

server.on "message", (msg, rinfo) ->
	console.log "server got: " + msg + " from " + rinfo.address + ":" + rinfo.port
	return

server.on "listening", ->
	address = server.address()
	console.log "server listening " + address.address + ":" + address.port
	sendMsg()
	return

sendMsg = () ->
	cmdmsg[2] = 11  # fill solid = 8, fill gradient = 11
	cmdmsg[4] = Math.floor(n / 256)
	cmdmsg[5] = Math.floor(n % 256)  # start at nth led
	cmdmsg[7] = 1  # fill nn leds
	cmdmsg[8] = 255    # start with colour 
	cmdmsg[11] = 255   # end with colour

	console.log "Sending " + k + " len " + cmdmsg.length

	server.send cmdmsg, 0, cmdmsg.length, PORT, IPADDR, (err, bytes) ->
		if err then throw err
		console.log err + " bytes " + bytes
		setTimeout nextStep, 100

	console.log ("here22")

	return

nextStep = () ->
	n++
	if n >= TOTLEDS
		n = 0
	k++
	if k == 100
		server.close()
		console.log "Done"
	else
		sendMsg()
		console.log ("Here")

server.bind(PORT)
