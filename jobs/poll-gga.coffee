# galegis-api -- Structured Importing and RESTful providing of GA General Assembly Activity.
# Copyright (C) 2013 Matthew Farmer - Distributed Under the GNU AGPL 3.0. See LICENSE at project root.
module.exports = (jobs, db) ->
  moment = require('moment')

  msUntilNextMonth = ->
    startOfNextMonth = moment().startOf('month').add('months', 1)
    startOfNextMonth.diff(moment(), 'milliseconds')

  msUntilNextWeek = ->
    startOfNextWeek = moment().startOf('week').add('weeks', 1)
    startOfNextWeek.diff(moment(), 'milliseconds')

  msUntilNextDay = ->
    startOfNextDay = moment().startOf('day').add('days', 1)
    startOfNextDay.diff(moment(), 'milliseconds')

  msUntilNextHour = ->
    startOfNextHour = moment().startOf('hour').add('hours', 1)
    startOfNextHour.diff(moment(), 'milliseconds')

  pollJobWithCurrentSession = (options) ->
    {createPollJobFn, createJobFn, callback} = options

    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      if err
        createPollJobFn()
        callback(err)
        return

      if ! currentSession?
        createPollJobFn()
        callback("No current session found.")
        return

      createJobFn(currentSession)
      createPollJobFn()
      callback()

  jobs.process 'poll sessions', (job, callback) ->
    jobs.create('import sessions').save()
    jobs.create('poll sessions').delay(msUntilNextMonth()).save()

    callback()

  jobs.process 'poll members', (job, callback) ->
    pollJobWithCurrentSession
      createJobFn: (currentSession) ->
        jobs.create('import all members for session', session: currentSession).save()
      createPollJobFn: ->
        jobs.create('poll members').delay(msUntilNextWeek()).save()
      callback: callback

  jobs.process 'poll committees', (job, callback) ->
    pollJobWithCurrentSession
      createJobFn: (currentSession) ->
        jobs.create('import committees for session', session: currentSession).save()
      createPollJobFn: ->
        jobs.create('poll committees').delay(msUntilNextWeek()).save()
      callback: callback

  jobs.process 'poll legislation', (job, callback) ->
    pollJobWithCurrentSession
      createJobFn: (currentSession) ->
        jobs.create('import legislation for session', session: currentSession).save()
      createPollJobFn: ->
        jobs.create('poll legislation').delay(msUntilNextDay()).save()
      callback: callback

  jobs.process 'poll votes', (job, callback) ->
    pollJobWithCurrentSession
      createJobFn: (currentSession) ->
        jobs.create('import all votes for session', session: currentSession).save()
      createPollJobFn: ->
        jobs.create('poll votes').delay(msUntilNextDay()).save()
      callback: callback
