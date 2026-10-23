class Favirecon < Formula
  desc "Uses favicon.ico to improve the target recon phase"
  homepage "https://edoardottt.com/"
  url "https://github.com/edoardottt/favirecon/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "3cc64b241fc357cda44ea11ffbe036fbf7160049d0011c45a9963746e6e27bfb"
  license "MIT"
  head "https://github.com/edoardottt/favirecon.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "615ad08b84ea29b681a4221a8a59d17cc8af77a40b46dbf04de7fc64b34d5337"
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
