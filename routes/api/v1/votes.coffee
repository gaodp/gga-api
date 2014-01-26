# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (app, jobs, db) ->
  api = require('../../../api/v1/votes')({}, db)

  app.get '/api/v1/votes', api.v1.getVotes
  app.get '/api/v1/vote/:vote', api.v1.getVoteById
