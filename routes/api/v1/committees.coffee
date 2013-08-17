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
ObjectId = require('mongodb').ObjectID;

module.exports = (app, db) ->
  # GET /api/v1/committees - Retrieve all members for a particular sesson.
  # (Defaults to current session.)
  app.get '/api/v1/committees', (req, res) ->
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

      db.collection("committees").find({sessionId: selectedSessionId}).toArray (err, results) ->
        if err
          errorId = Math.random().toString(36).substring(7)
          console.error("Error " + errorId + ": " + err)

          res.json
            id: errorId,
            error: err
          , 500

          return

        res.json(results)

  # GET /api/v1/committee/:id
  app.get '/api/v1/committee/:id', (req, res) ->
    try
      committeeObjectId = new ObjectId req.params.id
    catch
      errorOutput =
        fieldId: "committeeId",
        error: "invalid",
        message: "The committee id you requested was not a valid identifier. Identifiers should conform to MongoDB's ObjectID format."

      res.json errorOutput, 417
      return

    db.collection("committees").findOne {_id: committeeObjectId}, (err, committee) ->
      if err
        errorId = Math.random().toString(36).substring(7)
        console.error("Error " + errorId + ": " + err)

        res.json
          id: errorId,
          error: err
        , 500

        return

      if committee?
        res.json committee
      else
        res.send 404
