chai = require 'chai'
request = require 'request'
chai.should()

module.exports =
  validatePage: validatePage = (path, done) ->
    request 'http://localhost:3000/api/v1/' + path, (error, response, body) ->
      response.statusCode.should.equal 200
      done()

  houseOrSenate: houseOrSenate = (type) ->
    type.toLowerCase() == "house" or type.toLowerCase() == "senate"

  billOrResolution: billOrResolution = (type) ->
    type.toLowerCase() == "bill" or type.toLowerCase() == "resolution"