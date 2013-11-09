# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
express = require('express')
http = require('http')
path = require('path')
kue = require('kue')
MongoClient = require('mongodb').MongoClient
requireFu = require('require-fu')

mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

jobs = kue.createQueue()
app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.cookieParser('your secret here'))
app.use(express.session())
app.use(app.router)
app.use(require('stylus').middleware(__dirname + '/public'))
app.use(express.static(path.join(__dirname, 'public')))

# development only
if 'development' == app.get('env')
  app.use(express.logger('dev'))
  app.use(express.errorHandler())
  app.use('/kue', kue.app)

# production only
if 'production' == app.get('env')
  mongoUrl = "mongodb://127.0.0.1:27017/galegis-api"

  app.use(express.logger('default'))

  kueUser = process.env.KUEUSER || "kue"
  kuePass = process.env.KUEPASS || "kue"
  app.use('/kue', express.basicAuth(kueUser, kuePass), kue.app)

mongoOptions =
  db:
    w: 1
  server:
    poolSize: 10
    auto_reconnect: true

MongoClient.connect mongoUrl, mongoOptions, (err, db) ->
  # Load up routes
  requireFu(__dirname + '/routes')(app, jobs, db)

  # Boot HTTP server
  http.createServer(app).listen app.get('port'), () ->
    console.log('Express server listening on port ' + app.get('port'))

  # Boot up job processing system.
  requireFu(__dirname + '/jobs')(jobs, db)
