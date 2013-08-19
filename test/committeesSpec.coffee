helpers = require './testHelpers'
chai = require 'chai'
MongoClient = require 'mongodb'
http = require 'http'

validatePage = helpers.validatePage
chai.should()
MongoClient.MongoClient

describe 'Committees', ->

  it 'should return 200 when we hit /api/v1/committees', (done) ->
    validatePage("committees", done)
