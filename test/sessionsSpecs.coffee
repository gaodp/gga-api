helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
chai.should()

describe 'Sessions', ->
  page = 'sessions'

  it 'should return 200 when we hit /api/v1/sessions', (done) ->
    validatePage(page, done)

  it 'should all contain the correct data types', (done) ->
    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.be.a('string')
        entry.assemblyId.should.be.a('number')
        entry.current.should.be.a('boolean')
        entry.name.should.be.a('string')

      done()
