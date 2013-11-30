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

  msUntilNextHour = ->
    startOfNextHour = moment().startOf('hour').add('hours', 1)
    startOfNextHour.diff(moment(), 'milliseconds')

  jobs.process 'poll sessions', (job, callback) ->
    jobs.create('import sessions').save()
    jobs.create('poll sessions').delay(msUntilNextMonth()).save()

    callback()

  jobs.process 'poll members', (job, callback) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      if err
        jobs.create('poll members').delay(msUntilNextWeek()).save()
        callback(err)
        return

      if ! currentSession?
        jobs.create('poll members').delay(msUntilNextWeek()).save()
        callback("No current session found.")
        return

      jobs.create('import all members for session', session: currentSession).save()
      jobs.create('poll members').delay(msUntilNextWeek()).save()
      callback()

  jobs.process 'poll committees', (job, callback) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      if err
        jobs.create('poll committees').delay(msUntilNextWeek()).save()
        callback(err)
        return

      if ! currentSession?
        jobs.create('poll committees').delay(msUntilNextWeek()).save()
        callback("No current session found.")
        return

      jobs.create('import committees for session', session: currentSession).save()
      jobs.create('poll committees').delay(msUntilNextWeek()).save()
      callback()

  jobs.process 'poll legislation', (job, callback) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      if err
        jobs.create('poll legislation').delay(msUntilNextHour()).save()
        callback(err)
        return

      if ! currentSession?
        jobs.create('poll legislation').delay(msUntilNextHour()).save()
        callback("No current session found.")
        return

      jobs.create('import legislation for session', session: currentSession).save()
      jobs.create('poll legislation').delay(msUntilNextHour()).save()
      callback()

  jobs.process 'poll votes', (job, callback) ->
    db.collection("sessions").findOne {current: true}, (err, currentSession) ->
      if err
        jobs.create('poll votes').delay(msUntilNextHour()).save()
        callback(err)
        return

      if ! currentSession?
        jobs.create('poll votes').delay(msUntilNextHour()).save()
        callback("No current session found.")
        return

      jobs.create('import all votes for session', session: currentSession).save()
      jobs.create('poll votes').delay(msUntilNextHour()).save()
      callback()
