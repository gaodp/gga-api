#!/bin/bash

nohup coffee app.coffee &
sleep 2
pid=$!
npm test
testResult=$?
kill $pid
exit $testResult
