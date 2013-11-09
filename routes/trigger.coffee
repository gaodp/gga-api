# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  app.get '/trigger/sessions', (req, res) ->
    jobs.create('import sessions').save()
    res.send 200

  app.get '/trigger/members', (req, res) ->
    jobs.create('import members').save()
    res.send 200

  app.get '/trigger/committees', (req, res) ->
    jobs.create('import committees').save()
    res.send 200

  app.get '/trigger/legislation', (req, res) ->
    jobs.create('import legislation').save()
    res.send 200

  app.get '/trigger/votes', (req, res) ->
    jobs.create('import all votes').save()
    res.send 200

  app.get '/trigger/votes/session/:legislativeSession', (req, res) ->
    jobs.create('import all votes for session', session: req.legislativeSession).save()
    res.send 200

  app.get '/trigger/votes/vote/:legislativeSession/:assemblyVoteId', (req, res) ->
    jobs.create('import vote', voteId: req.assemblyVoteId, session: req.legislativeSession).save()
    res.send 200
