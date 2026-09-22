class Favirecon < Formula
  desc "Uses favicon.ico to improve the target recon phase"
  homepage "https://edoardottt.com/"
  url "https://github.com/edoardottt/favirecon/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "61ce4ceea1a11e1e39ec67dadafb4cf9b9749d18385a76774298e5441eca4391"
  license "MIT"
  head "https://github.com/edoardottt/favirecon.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "7d26a6a99fb5da0ded442cdc4acff3dc3960cd99fd203a05c737aa49360a52f2"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/favirecon"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/favirecon --help")

    output = shell_output("#{bin}/favirecon -u https://www.github.com -verbose 2>&1")
    assert_match "Checking favicon for https://www.github.com/favicon.ico", output
  end
end
