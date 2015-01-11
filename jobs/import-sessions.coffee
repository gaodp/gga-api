# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

await = require 'await'
soap = require 'soap'
sessionSvcUri = "./wsdl/Sessions.svc.xml"

persistSession = (session, db, promise) ->
  sessionInstance =
    name: session.Description,
    current: session.IsDefault,
    library: session.Library

  db.collection("sessions").update
    assemblyId: Number(session.Id)
  ,
    "$set": sessionInstance
  ,
    upsert: true
  , (err, doc) ->
    if err?
      promise.fail(err)
    else
      promise.keep('session', doc)

module.exports = (jobs, db) ->
  jobs.process 'import sessions', (job, callback) ->
    soap.createClient sessionSvcUri, (err, client) -> ifSuccessful err, callback, ->
      client.SessionService.BasicHttpBinding_SessionFinder.GetSessions (err, result, raw) ->
        ifSuccessful err, callback, ->
          sessions = result.GetSessionsResult.Session

          promises = sessions.map (session) ->
            await('session').run (promise) ->
              persistSession(session, db, promise)

          await.all(promises).onkeep((got) -> callback()).onfail(() -> callback([].slice.call(arguments).join('\n')))
