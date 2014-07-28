# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
express = require('express')
http = require('http')
path = require('path')
kue = require('kue')
MongoClient = require('mongodb').MongoClient
requireFu = require('require-fu')
morgan = require('morgan')
errorhandler = require('errorhandler')

# Set up the Job queue.
jobs = kue.createQueue()
jobs.on 'job complete', (id) ->
  kue.Job.get id, (err, job) ->
    return if err

    job.remove (err) ->
      if err
        console.error err

# Set up Express.
app = express()
app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.set('mongo url', "mongodb://127.0.0.1:27017/galegis-api-dev")
app.use(require('stylus').middleware(__dirname + '/public'))
app.use(express.static(path.join(__dirname, 'public')))
app.set('json spaces', 2)

# Development environment settings.
if 'development' == app.get('env')
  app.use(morgan('dev'))
  app.use(errorhandler())
  app.use('/kue', kue.app)

# Production environment settings.
if 'production' == app.get('env')
  app.set('mongo url', "mongodb://127.0.0.1:27017/galegis-api")
  app.use(morgan('default'))

  kueUser = process.env.KUEUSER || "kue"
  kuePass = process.env.KUEPASS || "kue"

  app.use('/kue', express.basicAuth(kueUser, kuePass))
  app.use('/kue', kue.app)

mongoOptions =
  db:
    w: 1
  server:
    poolSize: 10
    auto_reconnect: true

MongoClient.connect app.get('mongo url'), mongoOptions, (err, db) ->
  # Load up routes
  requireFu(__dirname + '/routes')(app, jobs, db)

  # Boot HTTP server
  http.createServer(app).listen app.get('port'), () ->
    console.log('GGA-API is listening on port ' + app.get('port'))

  # Boot up job processing system.
  requireFu(__dirname + '/jobs')(jobs, db)
