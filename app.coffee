#    galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
#    Copyright (C) 2013 Matthew Farmer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
express = require('express')
http = require('http')
path = require('path')
kue = require('kue')
MongoClient = require('mongodb').MongoClient

mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

jobs = kue.createQueue()
app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.cookieParser('your secret here'))
app.use(express.session())
app.use(app.router)
app.use('/kue', kue.app)
app.use(require('stylus').middleware(__dirname + '/public'))
app.use(express.static(path.join(__dirname, 'public')))

# development only
if 'development' == app.get('env')
  app.use(express.errorHandler())

mongoOptions =
  db:
    w: 1
  server:
    poolSize: 10
    auto_reconnect: true

MongoClient.connect mongoUrl, mongoOptions, (err, db) ->
  # Load up routes
  require('./routes')(app, db)

  # Boot HTTP server
  http.createServer(app).listen app.get('port'), () ->
    console.log('Express server listening on port ' + app.get('port'))

  # Boot up job processing system.
  require('./jobs')(jobs, db)
