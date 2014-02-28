# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getVotes = (req, res) ->
    db.collection("votes").find({sessionId: req.apiRequestSessionId}).toArray (err, results) ->
      if err
        res.jsonp
          error: err
        , 500

        return

      res.jsonp(results)

  api.v1.getVoteById = (req, res) -> res.jsonp req.vote

  api
