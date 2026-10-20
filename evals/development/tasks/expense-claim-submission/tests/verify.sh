#!/usr/bin/env bash
set -euo pipefail
export RAILS_ENV=test
# Setup failures use exit 2 so the harness reports infrastructure failure.
bin/rails db:prepare > "$LOGS/database.log" 2>&1 || exit 2
set +e
bin/rails test > "$LOGS/baseline.log" 2>&1
baseline_result=$?
set -e
ruby -e 'm = File.read(ARGV[0]).match(/(\d+) runs, \d+ assertions, (\d+) failures, (\d+) errors, (\d+) skips/); exit(!m || m[1].to_i.zero? ? 2 : 0)' "$LOGS/baseline.log"
# A completed suite with assertions or application exceptions is a model failure.
# Signals, startup failures and missing summaries remain infrastructure failures.
if [ "$baseline_result" -eq 1 ]; then exit 1; fi
if [ "$baseline_result" -ne 0 ]; then exit 2; fi
set +e
bundle exec ruby -Itest -report-lemans "$TESTS/verification_test.rb" > "$LOGS/graded.log" 2>&1
result=$?
set -e
cat "$LOGS/graded.log"
# No results means a boot/load failure, not a failed business requirement.
test -s "$LOGS/checks.json" || exit 2
# Require a complete Minitest summary and one recorded check per executed test.
# Exceptions during completed tests fail requirements; missing/partial results do not.
ruby -rjson -e 'm = File.read(ARGV[0]).match(/(\d+) runs, \d+ assertions, (\d+) failures, (\d+) errors, (\d+) skips/); s = JSON.parse(File.read(ARGV[1])).fetch("checks").values; exit(!m || m[1].to_i.zero? || s.size != m[1].to_i || (s - %w[pass fail error skip]).any? ? 2 : 0)' "$LOGS/graded.log" "$LOGS/checks.json"
if [ "$result" -ne 0 ] && [ "$result" -ne 1 ]; then exit 2; fi
exit "$result"
