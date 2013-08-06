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
Apricot = require('apricot').Apricot
MongoClient = require('mongodb').MongoClient
mongoUrl = "mongodb://127.0.0.1:27017/galegis-api-dev"

sessionCollectionName = "sessions"
sessionScrapeUri = "http://www.legis.ga.gov/Legislation/en-US/VoteList.aspx"

persistNewSession = (db, assemblyId, name, callback) ->
  db.collection(sessionCollectionName).insert
    assemblyId: assemblyId,
    name: name,
    current: false
  ,
    safe: true
  , (err, doc) ->
    if err
      console.err err
      callback(err)
      return

    console.log "Created session " + doc[0].name + " under ID " + doc[0]._id
    callback()

clearActiveSessions = (db, callback) ->
  db.collection("sessions").update
    current: true
  ,
    "$set":
      "current": false
  ,
    safe: true
  , callback

markActiveSession = (db, callback) ->
  db.collection("sessions").find({}, "sort": [['assemblyId','desc']]).toArray (err, docs) ->
    if err
      console.error(err)
      callback(err)
      return

    if docs[0]
      db.collection("sessions").update
        "_id": docs[0]._id
      ,
        "$set":
          "current": true
      ,
        "safe": true
      , callback
    else
      callback()

module.exports = (jobs) ->
  jobs.process 'scrape sessions', (job, done) ->
    Apricot.open sessionScrapeUri, (err, doc) ->
      if err
        console.error(err)
        done(err)
        return

      doc.find("select[name=ctl00$SPWebPartManager1$g_f97fdca8_f858_400b_9279_a6a8f76ec618$Session] > *").each (elem) ->
        sessionId = Number(elem.value)
        sessionName = elem.innerHTML.trim()

        MongoClient.connect mongoUrl, (err, db) ->
          if err
            console.log(err)
            done(err)
            return

          db.collection("sessions").count {assemblyId: sessionId}, (err, count) ->
            if err
              console.log(err)
              done(err)
              return

            unless count == 0
              db.close()
              done()
            else
              console.log("Creating session " + sessionName + " " + sessionId)
              persistNewSession db, sessionId, sessionName, (err) ->
                if err
                  console.log(err)
                  done(err)
                  db.close()
                  return

                clearActiveSessions db, (err) ->
                  if err
                    done(err)
                    db.close()
                    return

                  markActiveSession db, (err) ->
                    if err
                      done(err)
                      db.close()
                      return

                    done()
                    db.close()
