# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  api = require('../../../api/v1/members')({}, db)

  app.get '/api/v1/members', api.v1.getMembers
  app.get '/api/v1/member/:member', api.v1.getMemberById
  app.get '/api/v1/member/:member/votes', api.v1.getMemberVotes
