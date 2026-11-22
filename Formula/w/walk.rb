class Walk < Formula
  desc "Terminal navigator"
  homepage "https://github.com/antonmedv/walk"
  url "https://github.com/antonmedv/walk/archive/refs/tags/v1.14.0.tar.gz"
  sha256 "1d611d683c6764de089971e838dd8462dc1d6e63b3faf1a8f8d2a144d7264a3e"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "11fa008851c3e3027ee7e7bf79bd0a43b9d3da016fcb102317b88e2119568f4d"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    require "pty"
    require "expect"

    PTY.spawn(bin/"walk") do |r, w, _pid|
      r.winsize = [80, 60]
      # walk waits for replies to its terminal background colour and cursor position queries
      r.expect("\e[6n", 10)
      w.write "\e]11;rgb:0000/0000/0000\e\\\e[1;1R"
      sleep 1
      w.write "\e"
      begin
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end
  end
end
