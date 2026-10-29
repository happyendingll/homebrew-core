class NewrelicCli < Formula
  desc "Command-line interface for New Relic"
  homepage "https://github.com/newrelic/newrelic-cli"
  url "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v0.115.6.tar.gz"
  sha256 "6252175d216f8e9cdf3d9515dac9f903b486271b14940296a3b414a38b0ebae8"
  license "Apache-2.0"
  head "https://github.com/newrelic/newrelic-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e30c75ab55098bb6cf90faac4fd92c0d4652c00b4250f32bb17743f6c57b4c01"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "dc71e5b7922ef7efbcd05944fb3b038aa25420cf1f027306ff5ae171f5ffe66c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a958c7d41877c0aa6376009d342c8b01d6bdf7ade10fd84b53b3d0b92da8e935"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "0880a66f8ed58df2db7e0139e4be039a254f035ad5f3110019a276ec4ee73587"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "0067f3220585f5315338128e8e15c77bc761658f0bb802d4e97f503738994e1f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["PROJECT_VER"] = version
    system "make", "compile-only"
    bin.install "bin/#{OS.kernel_name.downcase}/newrelic"

    generate_completions_from_executable(bin/"newrelic", "completion", "--shell")
  end

  test do
    output = shell_output("#{bin}/newrelic config list")

    assert_match "loglevel", output
    assert_match "plugindir", output
    assert_match version.to_s, shell_output("#{bin}/newrelic version 2>&1")
  end
end
