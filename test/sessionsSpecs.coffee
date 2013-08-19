helpers = require './testHelpers'
chai = require 'chai'
MongoClient = require 'mongodb'
http = require 'http'

validatePage = helpers.validatePage
chai.should()
MongoClient.MongoClient

describe 'Sessions', ->

  it 'should return 200 when we hit /api/v1/sessions', (done) ->
    validatePage("sessions", done)

  it 'should populate the sessions collection', (done) ->
    MongoClient.connect "mongodb://localhost:27017/galegis-api-dev", (err, db) ->
      db.collection('sessions').count (err, count) ->
        count.should.be.greaterThan 0
        done()