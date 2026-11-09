class Chiko < Formula
  desc "Ultimate Beauty gRPC Client for your Terminal"
  homepage "https://github.com/felangga/chiko"
  url "https://github.com/felangga/chiko/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "8c12a560226944a1074e3cdf273d705c122a91e60d4f3316e472e804ab56b697"
  license "MIT"
  head "https://github.com/felangga/chiko.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3d6d3332c2b714ba0552c683f49145f983b9c17823d0c0145f2f41785cb6d055"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/chiko"
  end

  test do
    ENV["TERM"] = "xterm"
    require "pty"

    PTY.spawn(bin/"chiko") do |r, w, _pid|
      w.write "q"
      assert_match "Chiko dev", r.read
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    end
  end
end
