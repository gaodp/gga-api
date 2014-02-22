# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getSessions = (req, res) ->
    db.collection("sessions").find().toArray (err, results) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.jsonp
          id: errorId,
          error: err
        , 500

        return

      res.jsonp results

  api.v1.getSessionById = (req, res) -> res.jsonp req.legislativeSession

  api
