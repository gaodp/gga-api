helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
optionMatch = helpers.optionMatch
chai.should()

describe 'Legislation API Resource', ->
  page = "legislation"

  it 'should return correct data types', (done) ->
    validatePage(page)

    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.be.a('string')
        (+entry.assemblyId).should.be.a('number')
        optionMatch(entry.chamber, ['house', 'senate']).should.be.ok
        entry.code.should.be.a('string')
        (+entry.number).should.be.a('number')
        entry.sessionId.should.be.a('string')
        entry.title.should.be.a('string')
        optionMatch(entry.type, ['bill', 'resolution']).should.be.ok

      done()