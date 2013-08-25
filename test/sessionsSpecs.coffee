helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
chai.should()

describe 'Sessions API resource', ->
  page = 'sessions'

  it 'should return correct data types', (done) ->
    validatePage(page)

    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.be.a('string')
        entry.assemblyId.should.be.a('number')
        entry.current.should.be.a('boolean')
        entry.name.should.be.a('string')

      done()
