class LicenseEye < Formula
  desc "Tool to check and fix license headers and resolve dependency licenses"
  homepage "https://skywalking.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=skywalking/eyes/0.9.0/skywalking-license-eye-0.9.0-src.tgz"
  mirror "https://archive.apache.org/dist/skywalking/eyes/0.9.0/skywalking-license-eye-0.9.0-src.tgz"
  sha256 "59265a26cbf51f24eeace490eab59c82513c7428d7ca26e004df8e94756027e6"
  license "Apache-2.0"
  head "https://github.com/apache/skywalking-eyes.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "60031ffbe392fab5632dbec7672e9e7f7051a3009444e70e2ed6bdcc79b4e15a"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/apache/skywalking-eyes/commands.version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/license-eye"

    generate_completions_from_executable(bin/"license-eye", shell_parameter_format: :cobra)
  end

  test do
    output = shell_output("#{bin}/license-eye dependency check")
    assert_match "Loading configuration from file: .licenserc.yaml", output
    assert_match "Config file .licenserc.yaml does not exist, using the default config", output

    assert_match version.to_s, shell_output("#{bin}/license-eye --version")
  end
end
