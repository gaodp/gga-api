helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
pageBody = helpers.pageBody
chai.should()

describe 'Sessions', ->
  page = 'sessions'

  it 'should return 200 when we hit /api/v1/sessions', (done) ->
    validatePage(page, done)

  it 'should all contain the correct data types', (done) ->
    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.exist.and.be.a('string')
        entry.assemblyId.should.exist.and.be.a('number')
        entry.current.should.exist.and.be.a('boolean')
        entry.name.should.exist.and.be.a('string')

      done()
