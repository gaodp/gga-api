# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (app, db) ->
  # GET /api/v1/votes - Retrieve all votes.
  app.get '/api/v1/votes', (req, res) ->
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

      db.collection("votes").find({sessionId: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/vote/:id - Retrieve all information on a particular vote.
  app.get '/api/v1/vote/:id', (req, res) ->
    try
      voteObjectId = new ObjectId req.params.id
    catch
      errorOutput =
        fieldId: "voteId",
        error: "invalid",
        message: "The vote id you requested was not a valid identifier. Identifiers should conform to MongoDB's ObjectID format."

      res.json errorOutput, 417
      return

    db.collection("votes").findOne {_id: voteObjectId}, (err, vote) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      if vote?
        res.json vote
      else
        res.send 404
