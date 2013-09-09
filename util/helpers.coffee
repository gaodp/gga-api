# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports =
  ifSuccessful: (err, errHandler, successHandler) ->
    if err
      errHandler(err)
    else
      successHandler()

