# frozen_string_literal: true

require "spec_helper"
require "open3"
require "pty"
require "tmpdir"

# Hermetic tests for bin/guard-protected-branch. Each example shells out to
# the real script inside a throwaway git repository so no state leaks into
# (or out of) the developer's working copy.
#
# Contributor detection under test:
# - AI Contributor (AC): any of CLAUDE_CODE / CODEX / GITHUB_COPILOT_AGENT
#   set, OR stdin is not a TTY (fail-closed fallback for unknown AC tools).
# - Human Contributor (HC): none of those variables set AND stdin is a TTY.
#
# Open3.capture3 attaches a pipe to stdin (not a TTY), so the HC case uses
# PTY.spawn to give the child process a real controlling terminal.
RSpec.describe "bin/guard-protected-branch" do
  let(:script) { File.expand_path("../../bin/guard-protected-branch", __dir__) }

  # Explicitly unset every known AC variable (nil removes the variable from
  # the child environment) so each example fully controls contributor type.
  let(:hc_env) do
    { "CLAUDE_CODE" => nil, "CODEX" => nil, "GITHUB_COPILOT_AGENT" => nil }
  end

  let(:ac_env) { hc_env.merge("CLAUDE_CODE" => "1") }

  def init_repo(dir, branch: "main")
    system("git", "init", "--quiet", "--initial-branch", branch, chdir: dir, exception: true)
    system("git", "-C", dir, "config", "user.email", "spec@example.com", exception: true)
    system("git", "-C", dir, "config", "user.name", "Spec Runner", exception: true)
    system("git", "-C", dir, "commit", "--quiet", "--allow-empty", "-m", "init", exception: true)
  end

  # Runs the guard with a pipe on stdin (not a TTY).
  def run_guard(env, dir)
    Open3.capture3(env, script, "commit", chdir: dir)
  end

  # Runs the guard with a pseudo-terminal on stdin so the child sees a TTY,
  # exactly like a human typing `git commit` in an interactive shell.
  def run_guard_with_tty(env, dir)
    status = nil
    Dir.chdir(dir) do
      PTY.spawn(env, script, "commit") do |reader, _writer, pid|
        begin
          reader.read
        rescue Errno::EIO
          # The child exited and closed its side of the terminal.
        end
        _, status = Process.waitpid2(pid)
      end
    end
    status
  end

  context "with an AI Contributor (CLAUDE_CODE=1)" do
    it "blocks commits on main" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        _stdout, stderr, status = run_guard(ac_env, dir)

        expect(status.exitstatus).to eq(2)
        expect(stderr).to include("Blocked: cannot commit on protected branch 'main'")
      end
    end

    it "blocks commits on develop" do
      Dir.mktmpdir do |dir|
        init_repo(dir, branch: "develop")
        _stdout, stderr, status = run_guard(ac_env, dir)

        expect(status.exitstatus).to eq(2)
        expect(stderr).to include("Blocked: cannot commit on protected branch 'develop'")
      end
    end

    it "allows commits on a feature branch" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        system("git", "-C", dir, "checkout", "--quiet", "-b", "feature/spec-example", exception: true)
        _stdout, stderr, status = run_guard(ac_env, dir)

        expect(status.exitstatus).to eq(0)
        expect(stderr).to be_empty
      end
    end

    it "allows commits on a detached HEAD" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        system("git", "-C", dir, "checkout", "--quiet", "--detach", exception: true)
        _stdout, _stderr, status = run_guard(ac_env, dir)

        expect(status.exitstatus).to eq(0)
      end
    end

    it "fails closed outside a git repository" do
      Dir.mktmpdir do |dir|
        _stdout, stderr, status = run_guard(ac_env, dir)

        expect(status.exitstatus).not_to eq(0)
        expect(stderr).not_to be_empty
      end
    end
  end

  context "with a Human Contributor (no AC variables, interactive TTY)" do
    it "allows commits on main" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        status = run_guard_with_tty(hc_env, dir)

        expect(status.exitstatus).to eq(0)
      end
    end
  end

  context "with the no-TTY fallback (no AC variables, stdin is a pipe)" do
    it "still blocks commits on main" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        _stdout, stderr, status = run_guard(hc_env, dir)

        expect(status.exitstatus).to eq(2)
        expect(stderr).to include("Blocked: cannot commit on protected branch 'main'")
      end
    end
  end
end
