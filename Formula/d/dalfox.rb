class Dalfox < Formula
  desc "XSS scanner and utility focused on automation"
  homepage "https://dalfox.hahwul.com"
  url "https://github.com/hahwul/dalfox/archive/refs/tags/v3.2.4.tar.gz"
  sha256 "d86cae222a4db6c8a335013c980d0c6d672b3abee8cfb44da6ce1b489e4d3a9b"
  license "MIT"
  head "https://github.com/hahwul/dalfox.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "a8cae3425d1a42ca4ae559d0127bd57e95c877a2e4dd0f7f0da7ca1442be4f3e"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dalfox -V 2>&1")

    url = "https://pentest-ground.com:4280/vulnerabilities/xss_r/"
    output = shell_output("#{bin}/dalfox scan \"#{url}\" 2>&1", 1)
    assert_match "scan completed", output
  end
end
