class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "626329f1bdcd3e982c690a90e1147fc995584c69583f20ba7dfb6cc72419760e"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "40b8804d335ef27622491f96a3671e340b13ea8dc09de0b992f21bc8c6ffa08c"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/taproom --version")

    require "pty"
    require "expect"

    # taproom is a full-screen Homebrew TUI. Launch it in a pseudo-terminal and
    # confirm it boots and renders its data-loading screen, then quit cleanly.
    # The loading task labels are drawn before any network response, so this
    # exercises the real UI without depending on network access in CI.
    PTY.spawn(bin/"taproom", "--hide-columns", "Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Packages", 30), "taproom did not render its loading screen"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when reading from a closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
