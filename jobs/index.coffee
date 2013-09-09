# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (jobs, db) ->
  require('./import-sessions')(jobs, db)
  require('./import-members')(jobs, db)
  require("./import-committees")(jobs, db)
  require("./import-legislation")(jobs, db)
  require("./import-votes")(jobs, db)
