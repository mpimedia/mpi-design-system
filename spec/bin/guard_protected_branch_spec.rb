# frozen_string_literal: true

require "spec_helper"
require "fileutils"
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
#
# NOTE on invocation paths: the PTY-based HC example invokes the script
# DIRECTLY and tests the script's own detection logic (TTY on fd 0 means
# human, therefore exempt). That exemption is NOT reachable when the script
# runs as a git hook on git >= 2.36 — see the "through git hooks (known
# limitation)" context, which pins the end-to-end behavior.
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

  # Runs a command with a pseudo-terminal on stdin so the child sees a TTY,
  # exactly like a human typing in an interactive shell.
  # Returns [ output, status ].
  def run_with_tty(env, dir, *command)
    output = +""
    status = nil
    Dir.chdir(dir) do
      PTY.spawn(env, *command) do |reader, _writer, pid|
        begin
          output << reader.read
        rescue Errno::EIO
          # The child exited and closed its side of the terminal.
        end
        _, status = Process.waitpid2(pid)
      end
    end
    [ output, status ]
  end

  # Copies the repo's real hooks and guard into +dir+ and points
  # core.hooksPath at them, mirroring what bin/install-git-hooks does in a
  # working clone (copied rather than referenced so the throwaway repo is
  # fully self-contained: pre-commit resolves bin/guard-protected-branch
  # relative to its own repo root).
  def install_hooks(dir)
    repo_root = File.expand_path("../..", __dir__)
    FileUtils.mkdir_p(File.join(dir, "bin"))
    FileUtils.cp(File.join(repo_root, "bin", "guard-protected-branch"), File.join(dir, "bin"))
    FileUtils.cp_r(File.join(repo_root, ".githooks"), dir)
    FileUtils.chmod(0o755, Dir[File.join(dir, ".githooks", "*")] + [ File.join(dir, "bin", "guard-protected-branch") ])
    system("git", "-C", dir, "config", "core.hooksPath", File.join(dir, ".githooks"), exception: true)
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

  context "with a Human Contributor (no AC variables, interactive TTY, direct invocation)" do
    it "allows commits on main" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        _output, status = run_with_tty(hc_env, dir, script, "commit")

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

  # KNOWN LIMITATION (pinned deliberately, not a bug to fix here):
  #
  # git >= 2.36 runs hooks with stdin attached to /dev/null, so inside a
  # git hook `[[ ! -t 0 ]]` is always true and the guard classifies EVERY
  # git-layer invocation as an AI Contributor — the Human Contributor TTY
  # exemption tested above is unreachable through the git layer, even from
  # a real interactive terminal.
  #
  # Practical impact is low: the org flow is PR-based (nobody should commit
  # to main directly), and humans retain the explicit bypass
  # `git commit/push --no-verify`. ACs get no such path because the
  # agent-layer hook (.claude/hooks/enforce-branch-creation.sh) blocks them
  # regardless. bin/guard-protected-branch is a byte-identical port from
  # the Optimus template, which shares this trait; the finding should be
  # raised upstream in Optimus via the cross-repo-sync process rather than
  # forked locally. If this example ever fails, git's hook stdin behavior
  # has changed and both the guard and this documentation need review.
  context "through git hooks (known limitation)" do
    it "blocks even Human Contributors because git >= 2.36 gives hooks /dev/null stdin (bypass: --no-verify)" do
      Dir.mktmpdir do |dir|
        init_repo(dir)
        install_hooks(dir)
        output, status = run_with_tty(hc_env, dir, "git", "commit", "--allow-empty", "-m", "hc attempt")

        expect(status.exitstatus).not_to eq(0)
        expect(output).to include("Blocked: cannot commit on protected branch 'main'")
      end
    end
  end
end
