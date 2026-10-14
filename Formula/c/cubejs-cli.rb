class CubejsCli < Formula
  desc "Cube.js command-line interface"
  homepage "https://cube.dev/"
  url "https://registry.npmjs.org/cubejs-cli/-/cubejs-cli-1.8.5.tgz"
  sha256 "24f1c126dd121757f6c375980057eedd512669476c2c1951f8a7a8adc882d86a"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a65a61fa40dc3c9e54bc925935d990352cefc40ece1ba61040dd39e698a7cd3a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a65a61fa40dc3c9e54bc925935d990352cefc40ece1ba61040dd39e698a7cd3a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a65a61fa40dc3c9e54bc925935d990352cefc40ece1ba61040dd39e698a7cd3a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8b0344828c4170ae7ab986f579b69d290cd872602616037997514d09bc79a952"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "8b0344828c4170ae7ab986f579b69d290cd872602616037997514d09bc79a952"
  end

  depends_on "node"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "npm", "install", *std_npm_args(prefix: buildpath/"npm-fetch")
  end

  def install
    rm_r buildpath/"npm-fetch"
    system "npm", "install", "--offline", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    node_modules = libexec/"lib/node_modules/cubejs-cli/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cubejs --version")
    ENV["CI"] = "1" # Disable telemetry.
    token = "eyJhbGciOiJub25lIn0.eyJ1cmwiOiJodHRwczovL2V4YW1wbGUuY29tIn0."
    assert_match "Token successfully added!", shell_output("#{bin}/cubejs auth #{token}")
    config = JSON.parse((testpath/".cubecloud/config.json").read)
    assert_equal token, config.dig("auth", "https://example.com", "auth")
  end
end
