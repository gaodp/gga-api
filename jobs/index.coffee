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
  require('./scrape-sessions')(jobs)
  require('./scrape-vote-list')(jobs)

  jobs.process 'poll', (job, done) ->
    # Queue up jobs that should run on each poll.
    jobs.create('scrape sessions').save()
    jobs.create('scrape people').save()
    #jobs.create('scrape committees').save()
    #jobs.create('scrape legislation').save()
    #jobs.create('scrape votes').save()

    # Schedule the next poll.
    # todo

    done()

  # Create initial poll
  jobs.create('poll').save()
