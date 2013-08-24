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

committeesSvcUri = "./wsdl/Committees.svc.xml"

persistCommitteeMembers = (members, committee, session, db, callback) ->
  if ! members.forEach?
    members = [members]

  members.forEach? (member) ->
    db.collection("members").findOne {assemblyId: Number(member.Member.Id)}, (err, ourMember) -> ifSuccessful err, callback, ->
      unless ourMember?
        console.error("Member " + member.Member.Id + " is missing.")
        return

      memberKey = "members." + ourMember._id
      memberSet = {}
      memberSet[memberKey] = member.Role

      db.collection("committees").update
        sessionId: committee.sessionId,
        assemblyId: committee.assemblyId
      ,
        "$set": memberSet
      , (err) ->
        if err
          console.error "Something went wrong updating committees: " + err

persistCommittee = (assemblyCommittee, session, db, callback) ->
  members = assemblyCommittee.Members.CommitteeMember

  committeeDetails =
    sessionId: session._id,
    type: assemblyCommittee.Type.toLowerCase(),
    assemblyCode: assemblyCommittee.Code,
    assemblyId: assemblyCommittee.Id,
    name: assemblyCommittee.Name,
    description: assemblyCommittee.Description,
    members: {}

  db.collection("committees").update
    sessionId: committeeDetails.sessionId,
    assemblyId: committeeDetails.assemblyId
  ,
    committeeDetails
  ,
    upsert: true,
    safe: true
  , (err, doc) ->
    ifSuccessful err, callback, ->
      persistCommitteeMembers(members, committeeDetails, session, db, callback)
      callback()

module.exports = (jobs, db) ->
  jobs.process 'import committees', (job, callback) ->
    soap.createClient committeesSvcUri, (err, client) -> ifSuccessful err, callback, ->
      db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
        results.forEach (session) ->
          getCommitteesArgs =
            SessionId: session.assemblyId

          client.CommitteeService.BasicHttpBinding_CommitteeFinder.GetCommitteesBySession getCommitteesArgs, (err, result, raw) -> ifSuccessful err, callback, ->
            result.GetCommitteesBySessionResult.CommitteeListing.forEach (committeeBrief) ->
              getCommitteeForSessionArgs =
                CommitteeId: committeeBrief.Id
                SessionId: session.assemblyId

              client.CommitteeService.BasicHttpBinding_CommitteeFinder.GetCommitteeForSession getCommitteeForSessionArgs, (err, result, raw) -> ifSuccessful err, callback, ->
                persistCommittee(result.GetCommitteeForSessionResult, session, db, callback)
