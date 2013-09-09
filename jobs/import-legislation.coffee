# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
legislationSvcUri = "./wsdl/Legislation.svc.xml"

persistLegislationIndex = (session, legislationIndex, db, callback) ->
  assemblyIdForLegislation = Number(legislationIndex.Id)

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
