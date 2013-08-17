chai = require 'chai'
chai.should()
http = require('http');

describe 'Sessions', ->
  it 'should return 200 when we hit /triggers/session', (done) ->
    http.get 'http://localhost:3000/trigger/sessions', (res) ->
      res.statusCode.should.equal 200
      done();
