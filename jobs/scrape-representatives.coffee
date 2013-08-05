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

persistRepresentative = (session, assemblyMemberId, newRepresentative, callback) ->
  MongoClient.connect mongoUrl, (err, db) ->
    db.collection(peopleCollectionName).findOne
      generalAssemblyId: assemblyMemberId
    , (err, representative) ->
      if err
        callback err
        return

      # Representative exists...
      if representative
        db.collection(peopleCollectionName).update
          generalAssemblyId: assemblyMemberId
        ,
          "$push":
            activeSessions: session._id
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

scrapeRepresentativesForSession = (session, callback) ->
  # TODO

modules.exports = (jobs) ->
  jobs.process 'scrape representatives', (job, done) ->
    MongoClient.connect mongoUrl, (err, db) ->
      if err
        console.eror(err)
        done(err)
        return

      db.collection("sessions").find().toArray (err, sessions) ->
        db.close()

        if err
          console.error err
          done err
          return

        sessions.forEach (session) ->
          scrapeRepresentativeForSession session, (err) ->
            if err
              console.error err
              done err
              return
            else
              done()
              return
              
