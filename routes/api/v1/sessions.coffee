# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  # GET /api/v1/sessions - Retrieve all sessions.
  app.get '/api/v1/sessions', (req, res) ->
    db.collection("sessions").find().toArray (err, results) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      res.json results

  app.get '/api/v1/session/:legislativeSession', (req, res) ->
    res.json req.legislativeSession
