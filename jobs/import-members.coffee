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
MongoClient = require('mongodb').MongoClient
mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

membersSvcUri = "./wsdl/Members.svc.xml"

persistMember = (session, member, callback) ->
  # TODO

module.exports = (jobs) ->
  jobs.process 'import members', (job, callback) ->
    soap.createClient membersSvcUri, (err, client) -> ifSuccessful err, callback, ->
      MongoClient.connect mongoUrl, (err, db) -> ifSuccessful err, callback, ->
        db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
          db.close()

          results.forEach (session) ->
            getMembersArgs =
              SessionId: session.assemblyId

            client.MemberService.BasicHttpBinding_MemberFinder.GetMembersBySession getMembersArgs, (err, result, raw) -> ifSuccessful err, callback, ->
              result.GetMembersBySessionResult.MemberListing.forEach (member) ->
                persistMember session, member, callback

              callback()
