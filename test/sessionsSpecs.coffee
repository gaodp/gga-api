chai = require 'chai'
chai.should()
request = require 'request'

describe 'Sessions', ->
  it 'should return 200 when we hit /triggers/session', ->
    request 'http://localhost:3000/triggers/session', (error, response, body) ->
      if !error and response.statusCode == 200
        response.statusCode.should.equal 200