# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  api = require('../../../api/v1/legislation')({}, db)

  app.get '/api/v1/legislation', api.v1.getLegislation
  app.get '/api/v1/legislation/:legislation', api.v1.getLegislationById
  app.get '/api/v1/legislation/:type/:number', api.v1.getLegislationByTypeAndNumber
