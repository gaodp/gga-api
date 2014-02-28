# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.

module.exports = (app, jobs, db) ->
  ObjectId = require('mongodb').ObjectID;

  retrievalError = (error, res) ->
    res.json
      error: error
    , 500

  validObjectId = (possibleObjectId) ->
    try
      new ObjectId possibleObjectId
    catch
      error: "invalid",
      message: "That doesn't look like a valid object id."

  retrieveOrError = (collection, name) ->
    (req, res, next, id) ->
      validId = validObjectId(id)

      if validId.error?
        res.json validId, 417
        return

      db.collection(collection).findOne {_id: validId}, (err, result) ->
        if err
          retrievalError(err, res)
        else if result?
          req[name] = result
          next()
        else
          res.json
            error: "not_found",
            message: "That #{name} was not found."
          , 404

  app.param 'vote', retrieveOrError("votes", "vote")
  app.param 'member', retrieveOrError("members", "member")
  app.param 'committee', retrieveOrError("committees", "committee")
  app.param 'legislation', retrieveOrError("legislation", "legislation")
  app.param 'legislativeSession', retrieveOrError("sessions", "legislativeSession")
