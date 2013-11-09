# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID
await = require('await')

module.exports = (app, jobs, db) ->
  # GET /api/v1/members - Retrieve all members for a particular session.
  # (Defaults to current session.)
  app.get '/api/v1/members', (req, res) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      unless currentSession?
        err = "Could not find current session."
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      selectedSessionIdStr = req.query.sessionId || currentSession._id.toString()
      selectedSessionId = new ObjectId(selectedSessionIdStr)

      db.collection("members").find({sessions: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/member/:id - Retrieve all information on a particular member.
  app.get '/api/v1/member/:member', (req, res) ->
    res.json req.member

  # GET /api/v1/member/:id/votes - Retrieve all votes for a member.
  app.get '/api/v1/member/:member/votes', (req, res) ->
    memberObjectId = req.member._id

    votesPromise = await('yeas', 'nays', 'notvoteds', 'excuseds')

    votesPromise.onkeep (got) ->
      res.json
        yea: got.yeas,
        nay: got.nays,
        notvoted: got.notvoteds,
        excused: got.excuseds

    db.collection("votes").find({"votes.yea": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('yeas', results)

    db.collection("votes").find({"votes.nay": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('nays', results)

    db.collection("votes").find({"votes.notvoting": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('notvoteds', results)

    db.collection("votes").find({"votes.excused": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('excuseds', results)
