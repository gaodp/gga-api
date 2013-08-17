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

votesSvcUri = "./wsdl/Votes.svc.xml"

mapVoteMemberIds = (session, votesCast, db, callback) ->
  db.collection("members").find({sessions: session._id}).toArray (err, results) -> ifSuccessful err, callback, ->
    for voteType, assemblyMemberIds of votesCast
      votesCast[voteType] = assemblyMemberIds.map (assembyMemberId) ->
        matchingMember = results.filter (candidateMember) -> candidateMember.assemblyId == assembyMemberId
        matchingMember[0]?._id

    callback(votesCast)

persistVote = (session, vote, db, callback) ->
  assemblyIdForVote = vote.VoteId

  votesCast =
    yea: [],
    nay: [],
    notvoting: [],
    excused: [],
    unknown: []

  vote.Votes?.MemberVote.forEach (memberVote) ->
    voteName = memberVote.MemberVoted.toLowerCase()
    votesCast[voteName].push(memberVote.Member.Id)

  mapVoteMemberIds session, votesCast, db, (votes) ->
    voteDetails =
      sessionId: session._id,
      voteNumber: Number(vote.Number),
      dateTime: vote.Date,
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
              if typeof assemblyVoteSummary.Caption != 'string' || assemblyVoteSummary.Caption.toLowerCase() != "attendance"
                getVoteArgs =
                  VoteId: assemblyVoteSummary.VoteId

                client.VoteService.BasicHttpBinding_VoteFinder.GetVote getVoteArgs, (err, result, raw) ->
                  ifSuccessful err, callback, ->
                    persistVote(session, result.GetVoteResult, db, callback)
              else
                persistVote(session, assemblyVoteSummary, db, callback)

            callback()
