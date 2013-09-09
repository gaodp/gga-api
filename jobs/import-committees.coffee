# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
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
