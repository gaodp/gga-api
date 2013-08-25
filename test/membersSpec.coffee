helpers = require './testHelpers'
chai = require 'chai'
request = require 'request'

validatePage = helpers.validatePage
chai.should()

describe 'Members API resource', ->
  page = 'members'

  it 'should return correct data types', (done) ->
    validatePage(page)

    request 'http://localhost:3000/api/v1/' + page, (error, response, body) ->
      results = JSON.parse body

      for entry in results
        entry._id.should.be.a('string')
        (+entry.assemblyId).should.be.a('number')
        entry.firstName.should.be.a('string')
        entry.lastName.should.be.a('string')
        entry.type.should.be.a('string')
        entry.party.should.be.a('string').and.be.length(1)
        entry.district.should.be.a('number')
        entry.photoUri.should.be.a('string').and.contain("www")
        entry.districtAddress.should.be.ok
        entry.sessions.should.be.ok

      done()