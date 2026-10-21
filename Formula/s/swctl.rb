class Swctl < Formula
  desc "Apache SkyWalking CLI (Command-line Interface)"
  homepage "https://skywalking.apache.org/"
  url "https://github.com/apache/skywalking-cli/archive/refs/tags/0.15.0.tar.gz"
  sha256 "2b167a3f32939a6fa03363720e94d5c44e2e66563a5991627b109a2377883c7d"
  license "Apache-2.0"
  head "https://github.com/apache/skywalking-cli.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "80f527fbc86e4775c4dd89a15e7ad0d3d2c19002e1dd1e58c2aadc77d5922fb2"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/swctl"

    generate_completions_from_executable(bin/"swctl", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swctl --version 2>&1")

    output = shell_output("#{bin}/swctl --display yaml service ls 2>&1", 1)
    assert_match "level=fatal msg=\"Post \\\"http://127.0.0.1:12800/graphql\\\"", output
  end
end
