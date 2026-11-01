class Tetra < Formula
  desc "Tetragon CLI to observe, manage and troubleshoot Tetragon instances"
  homepage "https://tetragon.io/"
  url "https://github.com/cilium/tetragon/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "49538903f16bd08bfa24ff4b1bfb16c0edf93eebd730e072425200a4b21faed1"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "feae80394654d0157b480ca6e05f7c0d88e1c2473ad0e7d3885b3a8a6e92241f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/cilium/tetragon/pkg/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"tetra"), "./cmd/tetra"

    generate_completions_from_executable(bin/"tetra", shell_parameter_format: :cobra)
  end

  test do
    assert_match "CLI version: #{version}", shell_output("#{bin}/tetra version --build")
    event = '{"process_exec":{"process":{"binary":"/usr/bin/foo","arguments":"bar"}}}'
    assert_match "/usr/bin/foo bar", pipe_output("#{bin}/tetra getevents -o compact", event)
  end
end
