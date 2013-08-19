helpers = require './testHelpers'
chai = require 'chai'
http = require 'http'

validatePage = helpers.validatePage
chai.should()

describe 'Members', ->

  it 'should return 200 when we hit /api/v1/members', (done) ->
    validatePage("members", done)
