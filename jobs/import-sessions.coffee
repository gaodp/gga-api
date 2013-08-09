#   Copyright 2013 Matt Farmer
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
MongoClient = require('mongodb').MongoClient
mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

sessionSvcUri = "./wsdl/Sessions.svc.xml"

persistSession = (session, callback) ->
  sessionInstance =
    name: session.Description,
    current: (session.IsDefault.toLowerCase() == "true"),
    library: session.Library

  MongoClient.connect mongoUrl, (err, db) -> ifSuccessful err, callback, ->
    db.collection("sessions").update
      assemblyId: Number(session.Id)
    ,
      "$set": sessionInstance
    ,
      safe: true,
      upsert: true
    , (err, doc) ->
      db.close()

      ifSuccessful err, callback, ->
        callback()

module.exports = (jobs) ->
  jobs.process 'import sessions', (job, callback) ->
    soap.createClient sessionSvcUri, (err, client) -> ifSuccessful err, callback, ->
      client.SessionService.BasicHttpBinding_SessionFinder.GetSessions (err, result, raw) ->
        ifSuccessful err, callback, ->
          sessions = result.GetSessionsResult.Session
          persistSession(session, callback) for session in sessions
