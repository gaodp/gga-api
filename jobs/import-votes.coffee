# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
await = require 'await'
votesSvcUri = "./wsdl/Votes.svc.xml"
ObjectId = require('mongodb').ObjectID;

mapVoteMemberIds = (session, votesCast, db, callback) ->
  db.collection("members").find({sessions: session._id}).toArray (err, results) -> ifSuccessful err, callback, ->
    for voteType, assemblyMemberIds of votesCast
      votesCast[voteType] = assemblyMemberIds.map (assembyMemberId) ->
        matchingMember = results.filter (candidateMember) -> candidateMember.assemblyId == assembyMemberId
        matchingMember[0]?._id

    callback(votesCast)

persistVote = (session, vote, db, callback) ->
  session._id = new ObjectId(session._id)
  assemblyIdForVote = Number(vote.VoteId)

  votesCast =
    yea: [],
    nay: [],
    notvoting: [],
    excused: [],
    unknown: []

  vote.Votes?.MemberVote.forEach (memberVote) ->
    voteName = memberVote.MemberVoted.toLowerCase()
    votesCast[voteName].push(Number(memberVote.Member.Id))

  # Sometimes the date in the data that comes downwire is a string and other times
  # it is a proper date. Let's get things into a uniform format in our DB.
  fixedDate = if typeof vote.Date == 'string' then new Date(vote.Date) else vote.Date

  mapVoteMemberIds session, votesCast, db, (votes) ->
    voteDetails =
      sessionId: session._id,
      voteNumber: Number(vote.Number),
      dateTime: fixedDate,
      caption: vote.Caption,
      description: vote.Description,
      chamber: vote.Branch.toLowerCase(),
      votes: votes


    db.collection("votes").update
      assemblyId: assemblyIdForVote
    ,
      "$set": voteDetails
    ,
      upsert: true,
      safe: true
    , (err, doc) ->
      ifSuccessful err, callback, ->
        callback()

module.exports = (jobs, db) -> soap.createClient votesSvcUri, (err, client) ->
  throw err if err

  jobs.process 'import vote', 20, (job, callback) ->
    getVoteArgs = VoteId: job.data.voteId

    client.VoteService.BasicHttpBinding_VoteFinder.GetVote getVoteArgs, (err, result, raw) ->
      if err
        if job.data.assemblyVoteSummary
          job.log 'Persisting vote summary, as full vote information is unavailable.'
          persistVote(job.data.session, job.data.assemblyVoteSummary, db, callback)
        else
          callback(err)
      else
        job.log 'Persisting full vote information.'
        persistVote(job.data.session, result.GetVoteResult, db, callback)

  jobs.process 'import all votes for session', 5, (job, callback) ->
    for branch in ["House", "Senate"]
      getVotesArgs =
        Branch: branch
        SessionId: job.data.session.assemblyId

      console.log(getVotesArgs)

      client.VoteService.BasicHttpBinding_VoteFinder.GetVotes getVotesArgs, (err, result, raw) ->
        if err
          callback(err)
        else
          result.GetVotesResult.VoteListing?.forEach? (assemblyVoteSummary) ->
            if assemblyVoteSummary.Branch != branch
              return

            job.log 'Kueing up import vote job for ' + assemblyVoteSummary.VoteId

            voteJob = jobs.create 'import vote',
              assemblyVoteSummary: assemblyVoteSummary,
              voteId: assemblyVoteSummary.VoteId,
              session: job.data.session

            voteJob.save()

          callback()

  jobs.process 'import all votes', (job, callback) ->
    db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
      results.forEach (session) ->
        job.log "Kueing up import votes for session job for " + session._id
        jobs.create('import all votes for session', session: session).save()

      callback()
