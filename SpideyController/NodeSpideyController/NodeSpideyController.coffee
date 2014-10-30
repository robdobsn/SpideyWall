
# test using http://localhost:5078/rawcmd/01010b0200010001ff0000ff0000

http = require('http')
express = require('express')
MongoClient = require('mongodb').MongoClient
Server = require('mongodb').Server
path = require('path')
JSON = require('JSON')
spideyUdp = require('./spideyUdp')

spidey_UDP_IP = "192.168.0.227"
spidey_UDP_port = 7

console.log spideyUdp

# Spidey UDP is the controller for the spidey wall
spidey = new spideyUdp.SpideyUDP(spidey_UDP_IP, spidey_UDP_port)

# Express is the web server
app = express()
app.set 'port', process.env.PORT || 5078    # Arbitrarily chosen port number
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

app.all '*', (req, res, next) ->
	res.header "Access-Control-Allow-Origin", "*"
	res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
	next()

app.use express.static(__dirname + '/')

app.get '/scripts/all.json', (req, res) ->
	return res.send """
		{
			"scripts": 
			[
				{
				 	"name": "Snake", 
					"desc": "A snake program",
					"code": "var x = 10; function snake()"
				},
				{
				 	"name": "Snake2", 
					"desc": "Another snake program",
					"code": "var x = 10; function snake() { console.log ('hello'); }"
				}				
			]
		}
		"""

# Handle home page for web server
# app.get '/', (req, res) ->
# 	filePath = path.join(__dirname, '../public', 'index1.html')
# 	res.sendFile "index.html"

app.get '/rawcmd/:spideycommand', (req, res) ->
	spideycommand = req.params.spideycommand
	spidey.execCmd spideycommand
	res.send "ok"

app.use (req,res) ->
	res.render '404', {url:req.url}

http.createServer(app).listen app.get('port'), () ->
	console.log 'Spidey server listening on port ' + app.get('port')
