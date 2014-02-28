# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getVotes = (req, res) ->
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

      db.collection("votes").find({sessionId: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.jsonp
            id: errorId,
            error: err
          , 500

          return

        res.jsonp(results)

  api.v1.getVoteById = (req, res) -> res.jsonp req.vote

  api
