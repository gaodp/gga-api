helpers = require './testHelpers'
chai = require 'chai'
http = require 'http'

validatePage = helpers.validatePage
chai.should()

describe 'Legislation', ->

  it 'should return 200 when we hit /api/v1/legislation', (done) ->
    validatePage("legislation", done)
