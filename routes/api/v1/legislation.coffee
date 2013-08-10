#    galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
#    Copyright (C) 2013 Matthew Farmer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
module.exports = (app, db) ->
  # GET /api/v1/legislation - Get all matching legislation for query.
  app.get '/api/v1/legislation', (req, res) ->
    res.send(501)

  # GET /api/v1/legislation/:id - Get all info on individual legilsation
  app.get '/api/v1/legislation/:id', (req, res) ->
    res.send(501)

  # GET /api/v1/legislation/:type/:number - Retrieve a legilation type
  # by number
  app.get '/api/v1/legislation/:type/:number', (req, res) ->
    res.send(501)
