# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.

module.exports = (app, jobs, db) ->
  ObjectId = require('mongodb').ObjectID;

  retrievalError = (error, res) ->
    errorId = Math.random().toString(36).substring(7)
    console.error("Error " + errorId + ": " + err)

    res.json
      id: errorId,
      error: err
    , 500

  validObjectId = (possibleObjectId) ->
    try
      new ObjectId possibleObjectId
    catch
      error: "invalid",
      message: "That doesn't look like a valid object id."

  app.param 'committee', (req, res, next, id) ->
    committeeObjectId = validObjectId(id)

    if committeeObjectId.error?
      res.json committeeObjectId, 417
      return

    db.collection("committees").findOne {_id: committeeObjectId}, (err, committee) ->
      if err
        retrievalError(err, res)
      else if committee?
        req.committee = committee
        next()
      else
        res.json
          error: "not_found",
          message: "That committee was not found."
        , 404

  app.param 'legislation', (req, res, next, id) ->
    legislationObjectId = validObjectId(id)

    if legislationObjectId.error?
      res.json legislationObjectId, 417
      return

    db.collection("legislation").findOne {_id: legislationObjectId}, (err, legislation) ->
      if err
        retrievalError(err, res)
      else if legislation?
        req.legislation = legislation
        next()
      else
        res.json
          error: "not_found",
          message: "That committee was not found."
        , 404
