# frozen_string_literal: true

# Exercise the actual pinned CLI/parser, stopping before Runner#run, Docker,
# verifiers or provider calls. Only configuration metadata is inspected.
require "lemans/cli"
require "tmpdir"
require "json"

module NoComputePricingRefresh
  def refresh_registry!(**) = true
end
Miniswen.singleton_class.prepend(NoComputePricingRefresh)

module InspectPreparedCLI
  def execute(runner, _store, tasks)
    raise "Wrong task filter" unless tasks.map(&:name) == ["at-archive-book-access"]
    agent = tasks.first.config.agent
    raise "Task placement changed" unless agent.name == "miniswen-installed"
    raise "Task limits changed" unless agent.timeout == 5400 && agent.step_limit == 400 && agent.exec_timeout == 300
    raise "Wrong model" unless runner.config.agent.models == ["gpustack/Qwen/Qwen3.5-4B"]
    raise "Wrong repetition" unless runner.config.attempts == 1 && runner.config.concurrency == 1
    raise "Wrong output cap" unless runner.config.agent.max_output_tokens == 32768
    puts JSON.generate(cli: "passed", compute_calls: 0, harness_runs: 0)
  end
end
Lemans::CLI.prepend(InspectPreparedCLI)

Dir.mktmpdir("staged-cli-") do |dir|
  ARGV.replace(["run", "--bench", File.expand_path("../vendor/ai-evals", __dir__),
                "--backend", "docker", "--model", "gpustack/Qwen/Qwen3.5-4B",
                "--max_output_tokens", "32768", "--task", "at-archive-book-access",
                "--attempts", "1", "--concurrency", "1", "--runs_dir", dir])
  load File.join(__dir__, "staged-harness.rb")
end
