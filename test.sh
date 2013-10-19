#!/bin/bash

nohup node_modules/.bin/coffee app.coffee &
sleep 2
pid=$!
npm test
testResult=$?
kill $pid
exit $testResult
