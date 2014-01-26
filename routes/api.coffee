# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.

module.exports = (app, jobs, db) ->
  api = {}

  api = require('../api/v1/committees')(api, db)
  api = require('../api/v1/legislation')(api, db)
  api = require('../api/v1/members')(api, db)
  api = require('../api/v1/sessions')(api, db)
  api = require('../api/v1/votes')(api, db)

  app.get '/api/v1/sessions', api.v1.getSessions 
  app.get '/api/v1/session/:legislativeSession', api.v1.getSessionById

  app.get '/api/v1/members', api.v1.getMembers
  app.get '/api/v1/member/:member', api.v1.getMemberById
  app.get '/api/v1/member/:member/votes', api.v1.getMemberVotes

  app.get '/api/v1/committees', api.v1.getCommittees
  app.get '/api/v1/committee/:committee', api.v1.getCommitteeById

  app.get '/api/v1/legislation', api.v1.getLegislation
  app.get '/api/v1/legislation/:legislation', api.v1.getLegislationById
  app.get '/api/v1/legislation/:type/:number', api.v1.getLegislationByTypeAndNumber

  app.get '/api/v1/votes', api.v1.getVotes
  app.get '/api/v1/vote/:vote', api.v1.getVoteById 
