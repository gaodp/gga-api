# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (app, jobs, db) ->
  # GET /api/v1/committees - Retrieve all members for a particular sesson.
  # (Defaults to current session.)
  app.get '/api/v1/committees', (req, res) ->
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

      db.collection("committees").find({sessionId: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/committee/:id
  app.get '/api/v1/committee/:id', (req, res) ->
    try
      committeeObjectId = new ObjectId req.params.id
    catch
      errorOutput =
        fieldId: "committeeId",
        error: "invalid",
        message: "The committee id you requested was not a valid identifier. Identifiers should conform to MongoDB's ObjectID format."

      res.json errorOutput, 417
      return

    db.collection("committees").findOne {_id: committeeObjectId}, (err, committee) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      if committee?
        res.json committee
      else
        res.send 404
