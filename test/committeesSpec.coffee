helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
chai.should()

describe 'Committees', ->
  page = 'committees'

  validateType = (type) ->
    type.toLowerCase() == "house" or type.toLowerCase() == "senate"

  it 'should return 200 when we hit /api/v1/committees', (done) ->
    validatePage(page, done)

  it 'should all contain the correct data types', (done) ->
    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.be.a('string')
        entry.sessionId.should.be.a('string')
        validateType(entry.type).should.be.ok
        entry.name.should.be.a('string')
        entry.assemblyCode.should.be.a('string')
        entry.description.should.exist
        entry.members.should.exist

        for key, value of entry.members
          key.should.be.a('string')
          value.should.be.a('string')

      done()