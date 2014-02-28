#import legislation detail for session gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID
await = require('await')

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getMembers = (req, res) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      unless currentSession?
        err = "Could not find current session."
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.jsonp
          id: errorId,
          error: err
        , 500

        return

      selectedSessionIdStr = req.query.sessionId || currentSession._id.toString()

      try
        selectedSessionId = new ObjectId(selectedSessionIdStr)
      catch err
        res.jsonp
          error: "Invalid session ID."
        , 500

        res.end
        return

      db.collection("members").find({sessions: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.jsonp
            id: errorId,
            error: err
          , 500

          return

        res.jsonp(results)

  api.v1.getMemberById = (req, res) -> res.jsonp req.member

  api.v1.getMemberVotes = (req, res) ->
    memberObjectId = req.member._id
    normalize = req.query.normalize || false

    votesPromise = await('yeas', 'nays', 'notvoteds', 'excuseds')

    votesPromise.onkeep (got) ->
      res.jsonp
        yea: got.yeas,
        nay: got.nays,
        notvoted: got.notvoteds,
        excused: got.excuseds

    db.collection("votes").find({"votes.yea": memberObjectId}, {votes: false}).toArray (err, results) ->
      if normalize
        results = results.map (result) -> result._id
      votesPromise.keep('yeas', results)

    db.collection("votes").find({"votes.nay": memberObjectId}, {votes: false}).toArray (err, results) ->
      if normalize
        results = results.map (result) -> result._id
      votesPromise.keep('nays', results)

    db.collection("votes").find({"votes.notvoting": memberObjectId}, {votes: false}).toArray (err, results) ->
      if normalize
        results = results.map (result) -> result._id
      votesPromise.keep('notvoteds', results)

    db.collection("votes").find({"votes.excused": memberObjectId}, {votes: false}).toArray (err, results) ->
      if normalize
        results = results.map (result) -> result._id
      votesPromise.keep('excuseds', results)

  api
