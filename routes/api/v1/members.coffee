#    galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
#    Copyright (C) 2013 Matthew Farmer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
ObjectId = require('mongodb').ObjectID
await = require('await')

module.exports = (app, db) ->
  # GET /api/v1/members - Retrieve all members for a particular session.
  # (Defaults to current session.)
  app.get '/api/v1/members', (req, res) ->
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

      db.collection("members").find({sessions: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/member/:id - Retrieve all information on a particular member.
  app.get '/api/v1/member/:id', (req, res) ->
    try
      memberObjectId = new ObjectId req.params.id
    catch
      errorOutput =
        fieldId: "memberId",
        error: "invalid",
        message: "The member id you requested was not a valid identifier. Identifiers should conform to MongoDB's ObjectID format."

      res.json errorOutput, 417
      return

    db.collection("members").findOne {_id: memberObjectId}, (err, member) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      if member?
        res.json member
      else
        res.send 404

  # GET /api/v1/member/:id/votes - Retrieve all votes for a member.
  app.get '/api/v1/member/:id/votes', (req, res) ->
    memberObjectId = new ObjectId req.params.id

    votesPromise = await('yeas', 'nays', 'notvoteds', 'excuseds')

    votesPromise.onkeep (got) ->
      res.json
        yea: got.yeas,
        nay: got.nays,
        notvoted: got.notvoteds,
        excused: got.excuseds

    db.collection("votes").find({"votes.yea": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('yeas', results)

    db.collection("votes").find({"votes.nay": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('nays', results)

    db.collection("votes").find({"votes.notvoting": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('notvoteds', results)

    db.collection("votes").find({"votes.excused": memberObjectId}).toArray (err, results) ->
      results = results.map (result) -> result._id
      votesPromise.keep('excuseds', results)
