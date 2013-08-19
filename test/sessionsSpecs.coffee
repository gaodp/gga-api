helpers = require './testHelpers'
chai = require 'chai'
http = require 'http'

validatePage = helpers.validatePage
chai.should()

describe 'Sessions', ->

  it 'should return 200 when we hit /api/v1/sessions', (done) ->
    validatePage("sessions", done)
