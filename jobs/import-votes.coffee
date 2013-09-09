# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
helpers = require '../util/helpers'
ifSuccessful = helpers.ifSuccessful

soap = require 'soap'
await = require 'await'
votesSvcUri = "./wsdl/Votes.svc.xml"

mapVoteMemberIds = (session, votesCast, db, callback) ->
  db.collection("members").find({sessions: session._id}).toArray (err, results) -> ifSuccessful err, callback, ->
    for voteType, assemblyMemberIds of votesCast
      votesCast[voteType] = assemblyMemberIds.map (assembyMemberId) ->
        matchingMember = results.filter (candidateMember) -> candidateMember.assemblyId == assembyMemberId
        matchingMember[0]?._id

    callback(votesCast)

persistVote = (session, vote, db, callback) ->
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

module.exports = (jobs, db) ->
  jobs.process 'import votes', (job, callback) ->
    soap.createClient votesSvcUri, (err, client) -> ifSuccessful err, callback, ->
      db.collection("sessions").find().toArray (err, results) -> ifSuccessful err, callback, ->
        results.forEach (session) ->
          getVotesArgs =
            SessionId: session.assemblyId

          client.VoteService.BasicHttpBinding_VoteFinder.GetVotes getVotesArgs, (err, result, raw) -> ifSuccessful err, callback, ->
            result.GetVotesResult.VoteListing?.forEach? (assemblyVoteSummary) ->
              getVoteArgs =
                VoteId: assemblyVoteSummary.VoteId

              client.VoteService.BasicHttpBinding_VoteFinder.GetVote getVoteArgs, (err, result, raw) ->
                if err
                  persistVote(session, assemblyVoteSummary, db, callback)
                else
                  persistVote(session, result.GetVoteResult, db, callback)

            callback()
