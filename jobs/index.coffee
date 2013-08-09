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
module.exports = (jobs) ->
  require('./import-sessions')(jobs)
  require('./import-members')(jobs)
  require("./import-committees")(jobs)
  require("./import-legislation")(jobs)
  require("./import-votes")(jobs)

  jobs.process 'poll', (job, done) ->
    # Queue up jobs that should run on each poll.
    jobs.create('import sessions').save()
    jobs.create('import members').save()
    jobs.create('import committees').save()
    jobs.create('import legislation').save()
    jobs.create('import votes').save()

    # Schedule the next poll.
    # todo

    done()

  # Create initial poll
  jobs.create('poll').save()
