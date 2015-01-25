#import legislation detail for session gga-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
ObjectId = require('mongodb').ObjectID
await = require('await')

memberVoteImplementation = (db, req, res, queryTransformer) ->
  memberObjectId = req.member._id
  normalize = req.query.normalize || false
  queryTransformer = queryTransformer || (thing)->thing

  votesPromise = await('yeas', 'nays', 'notvoteds', 'excuseds')

  votesPromise.onkeep (got) ->
    res.jsonp
      yea: got.yeas,
      nay: got.nays,
      notvoted: got.notvoteds,
      excused: got.excuseds

  db.collection("votes").find(
    queryTransformer({"votes.yea": memberObjectId}),
    {votes: false}
  ).toArray (err, results) ->
    if normalize
      results = results.map (result) -> result._id
    votesPromise.keep('yeas', results)

  db.collection("votes").find(
    queryTransformer({"votes.nay": memberObjectId}),
    {votes: false}
  ).toArray (err, results) ->
    if normalize
      results = results.map (result) -> result._id
    votesPromise.keep('nays', results)

  db.collection("votes").find(
    queryTransformer({"votes.notvoting": memberObjectId}),
    {votes: false}
  ).toArray (err, results) ->
    if normalize
      results = results.map (result) -> result._id
    votesPromise.keep('notvoteds', results)

  db.collection("votes").find(
    queryTransformer({"votes.excused": memberObjectId}),
    {votes: false}
  ).toArray (err, results) ->
    if normalize
      results = results.map (result) -> result._id
    votesPromise.keep('excuseds', results)

module.exports = (api, db) ->
  api = api || {}
  api.v1 = api.v1 || {}

  api.v1.getMembers = (req, res) ->
    db.collection("members").find({sessions: req.apiRequestSessionId}).toArray (err, results) ->
      if err
        res.jsonp
          error: err
        , 500

        return

      res.jsonp(results)

  api.v1.getMemberById = (req, res) -> res.jsonp req.member

  api.v1.getMemberVotes = (req, res) ->
    memberVoteImplementation(db, req, res)

  api.v1.getMemberVotesBySession = (req, res) ->
    memberVoteImplementation db, req, res, (baseQuery) ->
      baseQuery.sessionId = req.legislativeSession

  api
