# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  api = require('../../../api/v1/sessions')({}, db)

  app.get '/api/v1/sessions', api.v1.getSessions 
  app.get '/api/v1/session/:legislativeSession', api.v1.getSessionById
