# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (app, jobs, db) ->
  # API v1
  require('./api/v1/sessions')(app, db)
  require('./api/v1/members')(app, db)
  require('./api/v1/committees')(app, db)
  require('./api/v1/legislation')(app, db)
  require("./api/v1/votes")(app, db)
  require("./trigger")(app, jobs, db)

  # Stock express homepage.
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'GGA REST API'
