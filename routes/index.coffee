# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
await = require("await")

module.exports = (app, jobs, db) ->
  urlsPromise = await('sessionId', 'memberId', 'committeeId', 'legislationId', 'voteId')

  urlsPromise.onkeep (got) ->
    app.get "/", (req, res) ->
      res.render 'index', got

  db.collection("sessions").findOne (err, result) ->
    urlsPromise.keep('sessionId', result?._id)

  db.collection("members").findOne (err, result) ->
    urlsPromise.keep('memberId', result?._id)

  db.collection("committees").findOne (err, result) ->
    urlsPromise.keep('committeeId', result?._id)

  db.collection("legislation").findOne (err, result) ->
    urlsPromise.keep('legislationId', result?._id)

  db.collection("votes").findOne (err, result) ->
    urlsPromise.keep('voteId', result?._id)
