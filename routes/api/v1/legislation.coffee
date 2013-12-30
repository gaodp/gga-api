# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (app, jobs, db) ->
  # GET /api/v1/legislation - Get all matching legislation for query.
  app.get '/api/v1/legislation', (req, res) ->
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

      db.collection("legislation").find({sessionId: selectedSessionId}).sort({number: 1}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/legislation/:id - Get all info on individual legilsation
  app.get '/api/v1/legislation/:legislation', (req, res) ->
    res.json req.legislation

  # GET /api/v1/legislation/:type/:number - Retrieve a legilation type
  # by number
  app.get '/api/v1/legislation/:type/:number', (req, res) ->
    type = req.params.type.toUpperCase()

    unless type == 'HR' || type == 'HB' || type == "SB" || type == "SR"
      res.json
        fieldId: "type",
        error: "invalid",
        message: "The legislation type must be one of HR, HB, SB, or SR."
      , 417
      return

    fullCode = type + " " + req.params.number

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

      db.collection("legislation").findOne {sessionId: selectedSessionId, code: fullCode}, (err, legislation) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(legislation)
