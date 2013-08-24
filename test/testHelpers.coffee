chai = require 'chai'
http = require 'http'
request = require 'request'
chai.should()

module.exports =
  validatePage: validatePage = (path, done) ->
    http.get 'http://localhost:3000/api/v1/' + path, (res) ->
      res.statusCode.should.equal 200
      done()