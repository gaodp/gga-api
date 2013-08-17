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
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
legislationSvcUri = "./wsdl/Legislation.svc.xml"

persistLegislationIndex = (session, legislationIndex, db, callback) ->
  assemblyIdForLegislation = legislationIndex.Id

  codeParts = legislationIndex.Description.split(" ")
  chamber = if codeParts[0][0] == 'H' then 'house' else 'senate'
  legType = if codeParts[0][1] == 'R' then 'resolution' else 'bill'
  number = codeParts[1]

  legislationIndex =
    sessionId: session._id,
    title: legislationIndex.Caption,
    code: legislationIndex.Description,
    chamber: chamber,
    type: legType,
    number: number

  db.collection("legislation").update
    assemblyId: assemblyIdForLegislation
  ,
    "$set": legislationIndex
  ,
    upsert: true,
    safe: true
  , (err, doc) ->
    ifSuccessful err, callback, ->
      callback()

module.exports = (jobs, db) ->
  jobs.process 'import legislation', (job, callback) ->
    soap.createClient legislationSvcUri, (err, client) -> ifSuccessful err, callback, ->
      db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
        results.forEach (session) ->
          getLegislationArgs =
            SessionId: session.assemblyId

          client.LegislationService.BasicHttpBinding_LegislationSearch.GetLegislationForSession getLegislationArgs, (err, result, raw) -> ifSuccessful err, callback, ->
            result.GetLegislationForSessionResult.LegislationIndex.forEach (legislationIndex) ->
              persistLegislationIndex session, legislationIndex, db, callback
