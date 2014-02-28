# gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID;

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getLegislationById = (req, res) -> res.jsonp req.legislation

  api.v1.getLegislation = (req, res) ->
    db.collection("legislation").find({sessionId: req.apiRequestSessionId}).sort({number: 1}).toArray (err, results) ->
      if err
        res.jsonp
          error: err
        , 500

        return

      res.jsonp(results)

  api.v1.getLegislationByTypeAndNumber = (req, res) ->
    type = req.params.type.toUpperCase()

    unless type == 'HR' || type == 'HB' || type == "SB" || type == "SR"
      res.jsonp
        fieldId: "type",
        error: "invalid",
        message: "The legislation type must be one of HR, HB, SB, or SR."
      , 417
      return

    fullCode = type + " " + req.params.number

    db.collection("legislation").findOne {sessionId: req.apiRequestSessionId, code: fullCode}, (err, legislation) ->
      if err
        res.jsonp
          error: err
        , 500

        return

      res.jsonp(legislation)


  api
