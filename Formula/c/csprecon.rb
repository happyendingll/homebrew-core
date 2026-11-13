class Csprecon < Formula
  desc "Discover new target domains using Content Security Policy"
  homepage "https://edoardottt.com/"
  url "https://github.com/edoardottt/csprecon/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "d5ac261e9afa4a5d84bcacf8583fbbe9e7ced73b4de9f40558b6e046d7e1f258"
  license "MIT"
  head "https://github.com/edoardottt/csprecon.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3ad622813f6859d37bfd5fc436726e5be16cd1a35a7e23e3145d7cafa1e60587"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/csprecon"
  end

  test do
    output = shell_output("#{bin}/csprecon -u https://brew.sh")
    assert_match "avatars.githubusercontent.com", output
  end
end
