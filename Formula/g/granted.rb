class Granted < Formula
  desc "Easiest way to access your cloud"
  homepage "https://granted.dev/"
  url "https://github.com/fwdcloudsec/granted/archive/refs/tags/v0.40.0.tar.gz"
  sha256 "93170305101876b6508f79f84f8a998f97ed7ffb9ec11d363088875297b00f4e"
  license "MIT"
  head "https://github.com/fwdcloudsec/granted.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7e1d7eee18e99bc896b20dc336fcc2df0d9c2f2a2847c879bcdc8fbc17028901"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -s -w
      -X github.com/fwdcloudsec/granted/internal/build.Version=#{version}
      -X github.com/fwdcloudsec/granted/internal/build.ConfigFolderName=.granted
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/granted"
    bin.install_symlink "granted" => "assumego"
    # these must be in bin, and not sourced automatically
    bin.install "scripts/assume"
    bin.install "scripts/assume.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/granted --version")

    ENV["XDG_CONFIG_HOME"] = testpath
    output = shell_output("#{bin}/granted registry add 2>&1", 1)
    assert_match "[✘] Required flags \"name, url\" not set", output

    ENV["GRANTED_ALIAS_CONFIGURED"] = "true"
    assert_match version.to_s, shell_output("#{bin}/assume --version")
    assert_match version.to_s, shell_output("#{bin}/assumego --version")

    # assume is interactive; pipe_output provides empty stdin causing prompts to fail.
    # Match varies by environment: "does not match" (with browser), "Could not find
    # default browser" (no browser configured), or "EOF" (when stdin closes).
    output = pipe_output("#{bin}/assume non-existing-role 2>&1", "")
    assert_match(/does not match any profiles|Could not find default browser|EOF/, output)
  end
end
