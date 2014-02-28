# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getCommitteeById = (req, res) -> res.jsonp req.committee

  api.v1.getCommittees = (req, res) ->
    db.collection("committees").find({sessionId: req.apiRequestSessionId}).toArray (err, results) ->
      if err
        res.jsonp
          error: err
        , 500

        return

      res.jsonp(results)

  api

