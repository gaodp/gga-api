chai = require 'chai'
request = require 'request'
chai.should()

module.exports =
  validatePage: validatePage = (path) ->
    request 'http://localhost:3000/api/v1/' + path, (error, response, body) ->
      response.statusCode.should.equal 200

  optionMatch: optionMatch = (type, options) ->
    options.some (match) -> ~type.indexOf match