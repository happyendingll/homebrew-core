class Ziggy < Formula
  desc "Data serialization language for expressing clear API messages, config files, etc"
  homepage "https://ziggy-lang.io"
  url "https://github.com/kristoff-it/ziggy/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "d3eff849a43a379740990aa4004368dbd7339344caa24bd7bf384e11733196df"
  license "MIT"
  head "https://github.com/kristoff-it/ziggy.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "846347730a2828d3e3b186aec1150ebb473c1289ebe21a0b6415f07b9f5022f9"
  end

  depends_on "zig" => :build

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    system "zig", "build", *std_zig_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ziggy version 2>&1")
    (testpath/"test.ziggy_schema").write <<~ZIGGY_SCHEMA
      $ = Root

      struct Root {
          a: bool,
          b: int,
      }
    ZIGGY_SCHEMA
    (testpath/"test.ziggy").write <<~ZIGGY
      .a = true,
      .b = 1,
    ZIGGY

    system bin/"ziggy", "check", "--schema", "test.ziggy_schema", "test.ziggy"
  end
end
