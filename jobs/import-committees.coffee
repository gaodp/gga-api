# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
ObjectId = require('mongodb').ObjectID
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

module.exports = (jobs, db) -> soap.createClient committeesSvcUri, (err, client) ->
  throw err if err

  jobs.process 'import committee for session', 20, (job, callback) ->
    # Ensure object IDs are in the correct format.
    job.data.session._id = new ObjectId(job.data.session._id)

    getCommitteeForSessionArgs =
      CommitteeId: job.data.committeeBrief.Id
      SessionId: job.data.session.assemblyId

    client.CommitteeService.BasicHttpBinding_CommitteeFinder.GetCommitteeForSession getCommitteeForSessionArgs, (err, result, raw) ->
      if err
        callback(err)
        return

      persistCommittee(result.GetCommitteeForSessionResult, job.data.session, db, callback)

  jobs.process 'import committees for session', 4, (job, callback) ->
    getCommitteesArgs =
      SessionId: job.data.session.assemblyId

    client.CommitteeService.BasicHttpBinding_CommitteeFinder.GetCommitteesBySession getCommitteesArgs, (err, result, raw) ->
      if err
        callback(err)
        return

      result.GetCommitteesBySessionResult.CommitteeListing.forEach (committeeBrief) ->
        jobs.create("import committee for session", committeeBrief: committeeBrief, session: job.data.session).save()

      callback()

  jobs.process 'import committees', (job, callback) ->
      db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
        results.forEach (session) ->
          job.log "Kueing up import for session job for " + session._id
          jobs.create("import committees for session", session: session).save()

        callback()
