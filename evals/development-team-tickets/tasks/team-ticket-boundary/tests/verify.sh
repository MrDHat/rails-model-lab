#!/usr/bin/env bash
set -euo pipefail
export RAILS_ENV=test
# Setup failures use exit 2 so the harness reports infrastructure failure.
bin/rails db:prepare > "$LOGS/database.log" 2>&1 || exit 2
set +e
bin/rails test > "$LOGS/baseline.log" 2>&1
baseline_result=$?
set -e
ruby -e 'm = File.read(ARGV[0]).match(/(\d+) runs, \d+ assertions, (\d+) failures, (\d+) errors, (\d+) skips/); exit(!m || m[1].to_i.zero? || m[3].to_i.positive? ? 2 : 0)' "$LOGS/baseline.log"
if [ "$baseline_result" -ne 0 ]; then exit 1; fi
set +e
bundle exec ruby -Itest -report-lemans "$TESTS/verification_test.rb" > "$LOGS/graded.log" 2>&1
result=$?
set -e
cat "$LOGS/graded.log"
# No results means a boot/load failure, not a failed business requirement.
test -s "$LOGS/checks.json" || exit 2
# Test exceptions need investigation rather than being silently counted as failures.
ruby -rjson -e 's = JSON.parse(File.read(ARGV[0])).fetch("checks").values; exit(s.empty? || s.include?("error") ? 2 : 0)' "$LOGS/checks.json"
exit "$result"
