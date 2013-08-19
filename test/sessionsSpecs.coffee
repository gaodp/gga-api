chai = require 'chai'
chai.should()
http = require 'http'
MongoClient = require 'mongodb'
MongoClient.MongoClient

describe 'Sessions', ->

  it 'should return 200 when we hit /api/v1/sessions', (done) ->
    http.get 'http://localhost:3000/api/v1/sessions', (res) ->
      res.statusCode.should.equal 200
      done()

  it 'should populate the sessions collection', (done) ->
    MongoClient.connect "mongodb://localhost:27017/galegis-api-dev", (err, db) ->
      db.collection('sessions').count (err, count) ->
        count.should.be.greaterThan 0
        done()