class Khaos < Formula
  desc "Kafka traffic simulator for observability and chaos engineering"
  homepage "https://github.com/aleksandarskrbic/khaos"
  url "https://github.com/aleksandarskrbic/khaos/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "e300394c907321c0e427da8eb7e80a510a9dc6f94cb86cc1ac1630dda376824f"
  license "Apache-2.0"
  head "https://github.com/aleksandarskrbic/khaos.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3f401abb4dd766d9f5686f7b736d18cb540bc037a6eee1b50f8859e210afc891"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/khaos"
    generate_completions_from_executable(bin/"khaos", shell_parameter_format: :cobra)
  end

  test do
    assert_match "Available Scenarios", shell_output("#{bin}/khaos list")
    assert_match version.to_s, shell_output("#{bin}/khaos --version")
  end
end
