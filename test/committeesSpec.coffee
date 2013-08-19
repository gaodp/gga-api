helpers = require './testHelpers'
chai = require 'chai'
http = require 'http'

validatePage = helpers.validatePage
chai.should()

describe 'Committees', ->

  it 'should return 200 when we hit /api/v1/committees', (done) ->
    validatePage("committees", done)
