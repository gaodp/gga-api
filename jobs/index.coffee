#   Copyright 2013 Matt Farmer
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
