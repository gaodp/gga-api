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
http = require('http')
Apricot = require('apricot').Apricot
MongoClient = require('mongodb').MongoClient
mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

peopleCollectionName = "people"

representativeScrapeUrl = "http://www.house.ga.gov/Representatives/en-US/HouseMembersList.aspx"
representativeProfileUrl = (memberId, sessionId) ->
  "http://www.house.ga.gov/Representatives/en-US/member.aspx?Member=" + memberId + "&Session=" + sessionId

persistRepresentative = (session, assemblyMemberId, newRepresentative, callback) ->
  MongoClient.connect mongoUrl, (err, db) ->
    if err
      console.error("Couldn't connect to mongo: " + err)
      callback err
      return

    db.collection(peopleCollectionName).findOne
      generalAssemblyId: assemblyMemberId
    , (err, representative) ->
      if err
        callback err
        db.close()
        return

      # Representative exists...
      if representative
        newRepresentative.sessions = representative.sessions

        unless newRepresentative.sessions.indexOf(session._id) > -1
          newRepresentative.sessions.push(session._id)

        db.collection(peopleCollectionName).update
          generalAssemblyId: assemblyMemberId
        ,
          newRepresentative
        ,
          safe: true
        , (err) ->
          if err
            callback err
          else
            callback()

      # Representative doesn't exist.
      else
        db.collection(peopleCollectionName).insert newRepresentative, {safe: true}, (err) ->
          if err
            callback err
            return
          else
            callback()

      db.close()

scrapeRepresentativeProfile = (session, assemblyMemberId, callback) ->
  Apricot.open representativeProfileUrl(assemblyMemberId, session.assemblyId), (err, doc) ->
    if err
      callback(err)
      return

    displayName = doc.find(".HouseH1").matches[0].innerHTML.trim()
    nameParts = displayName.split(" ")
    firstName = nameParts.shift()
    lastName = nameParts.join(" ")

    partyAndCity = doc.find(".normal").matches[0].innerHTML.split(" ")
    party = partyAndCity[0]
    city = partyAndCity[2]

    district = Number(doc.find(".normal:last-child").matches[0].innerHTML.replace("District ", ""))

    photoUri = "http://www.house.ga.gov" + doc.find("img[alt=Picture Not Found]").matches[0].src.replace("file://", "")

    newRepresentative =
      generalAssemblyId: assemblyMemberId,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      party: party,
      city: city,
      photoUri: photoUri,
      sessions: [session._id]

    persistRepresentative(session, assemblyMemberId, newRepresentative, callback)

scrapeRepresentativesForSession = (session, callback) ->
  Apricot.open representativeScrapeUrl, (err, doc) ->
    if err
      callback(err)
      return

    doc.find("#ctl00_SPWebPartManager1_g_95d7a129_1d7d_4ebf_bdca_6fc160c6ae6d > div > div > div:last-child a").each (repLink) ->
      repLinkParts = repLink.href.match(/.*Member=([0-9]+)&Session=([0-9]+)/)
      assemblyMemberId = repLinkParts[1]
      scrapeRepresentativeProfile(session, assemblyMemberId, callback)

module.exports = (jobs) ->
  jobs.process 'scrape representatives', (job, done) ->
    MongoClient.connect mongoUrl, (err, db) ->
      if err
        console.error(err)
        done(err)
        return

      # The General Assembly's site isn't listening to session ID's passed
      # into URLs on this page. Lulz.
      db.collection("sessions").find({current: true}).toArray (err, sessions) ->
        db.close()

        if err
          console.error err
          done err
          return

        sessions.forEach (session) ->
          scrapeRepresentativesForSession session, (err) ->
            if err
              console.error err
              done err
              return
            else
              done()
              return
              
