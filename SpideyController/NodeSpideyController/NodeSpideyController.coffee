
# test using http://localhost:5078/rawcmd/01010b0200010001ff0000ff0000

http = require('http')
express = require('express')
bodyParser = require('body-parser')
mongodb = require('mongodb')
path = require('path')
JSON = require('JSON')
spideyUdp = require('./spideyUdp')
ObjectID = require('mongodb').ObjectID

spidey_UDP_IP = "192.168.0.227"
spidey_UDP_port = 7

mongoDbUri = 'mongodb://macallan:27017/SpideyWall'

console.log spideyUdp

# Spidey UDP is the controller for the spidey wall
spidey = new spideyUdp.SpideyUDP(spidey_UDP_IP, spidey_UDP_port)

# Express is the web server
app = express()
app.set 'port', process.env.PORT || 5078    # Arbitrarily chosen port number
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

app.use(bodyParser.json())

app.all '*', (req, res, next) ->
	res.header "Access-Control-Allow-Origin", "*"
	res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
	next()

app.use '/', express.static(__dirname + '/static')

mongoDbCollection = null
mongoDb = null
app.get '/scripts', (req, res) ->
	console.log "Get all scripts"
	mongoDbCollection.find({}, { "id": true, "name": true }).toArray (err, docs) ->
		if err
			console.error "Error finding SpideyScripts"
			res.send "{}"
		else if docs is null
			console.error "Error finding SpideyScripts - doc null"
			res.send "{}"
		else
			res.send docs
		return
	return

app.get '/scripts/:id', (req, res) ->
	console.log "Get scripts id = " + req.params.id
	mongoDbCollection.findOne { _id: new ObjectID(req.params.id) }, (err, doc) ->
		if err isnt null
			console.error "Error finding SpideyScripts"
			res.send "{}"
		else if not doc
			console.error "Error finding SpideyScripts - doc null" + doc
			res.send "{}"
		else
			console.log "Found SpideyScripts"
			res.send doc
		return
	return

app.post '/scripts', (req, res) ->
	console.log "Create/Update script "
	# console.log "Body =  " + req.body
	isUpdate = req.body.isUpdate
	scriptName = req.body.name.trim()
	if scriptName is ""
		console.log "Name can't be blank"
		res.send { error: "nameisblank", ok: false }
		return
	newScript = req.body
	newScript.name = scriptName
	mongoDbCollection.findOne { name: scriptName }, (err, doc) ->
		if err isnt null
			console.log "Error in find script " + scriptName
			res.send { msg: err.message, error: "errorinfind", ok: false }
		else if doc isnt null
			if isUpdate
				mongoDbCollection.update { name: scriptName }, newScript
				console.log "Updated script ok .. id = " + newScript._id
				res.send { ok: true }
			else

				console.log "Name exists already"
				res.send { error: "nameexists", ok: false }
		else
			mongoDbCollection.save newScript
			console.log "Saved new script ok"
			res.send { ok: true }
		return
	return

app.delete '/scripts/:id', (req, res) ->
	console.log "Delete script id = " + req.params.id
	mongoDbCollection.findOne { _id: new ObjectID(req.params.id) }, (err, doc) ->
		if doc is null
			console.log "Script to delete not found"
			return res.send	{ error: "Not found", ok: false }
		mongoDbCollection.remove { _id: new ObjectID(req.params.id) }, (err, numberOfRemovedDocs) ->
			if err
				conole.log "Script delete failed"
				res.send { error: "deletefailed", msg: err.message, ok: false }
			else
				console.log "Script deleted ok - removed num docs = " + numberOfRemovedDocs
				res.send { ok: true }
			return
	return


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

# Mongo client
mongodb.MongoClient.connect mongoDbUri, (err, database) =>
	if err
		console.error "Error! MongoDB must be running ... " + err.message + "Shutting down"
		process.exit(1)
	mongoDb = database
	mongoDbCollection = mongoDb.collection('SpideyScripts')
	http.createServer(app).listen app.get('port'), () ->
		console.log 'Spidey server listening on port ' + app.get('port')

