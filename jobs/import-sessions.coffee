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

await = require 'await'
soap = require 'soap'
sessionSvcUri = "./wsdl/Sessions.svc.xml"

persistSession = (session, db, promise) ->
  sessionInstance =
    name: session.Description,
    current: (session.IsDefault.toLowerCase() == "true"),
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
