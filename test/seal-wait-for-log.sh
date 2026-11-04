#!/bin/sh
# Travis after_script helper (sealed build): keep the job open until Travis has
# archived this job's own log up to the QUnit summary line printed by
# test/seal-browser-runner.js. Travis archives log parts asynchronously, and a
# log fetched the moment the job ends can stop before the test results.
# after_script cannot change the build result, so this only delays job exit.
# The match pattern lives in this file so the echoed command line cannot match it.
url="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
pattern='QUnit summary: [0-9][0-9]* tests'
n=0
while [ "$n" -lt 90 ]; do
	if curl -fsSL "$url" 2>/dev/null | grep -Eq "$pattern"; then
		echo "seal-wait-for-log: archived log contains the test summary"
		exit 0
	fi
	n=$((n + 1))
	# Heartbeat: a silent loop trips Travis's 10-minute no-output kill (job "errored").
	echo "seal-wait-for-log: waiting for log archive ($n/90)"
	sleep 20
done
echo "seal-wait-for-log: archive still lacks the test summary after 30 minutes"
exit 0
