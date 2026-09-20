class Csprecon < Formula
  desc "Discover new target domains using Content Security Policy"
  homepage "https://edoardottt.com/"
  url "https://github.com/edoardottt/csprecon/archive/refs/tags/v0.4.7.tar.gz"
  sha256 "93f448d1c8b9f4b45e066fb84665410f554fc815cad75c9cb8aa1b0df2cceab5"
  license "MIT"
  head "https://github.com/edoardottt/csprecon.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "8941c05cca720a500b4d8f5d89f8c4313d359d6c63f1a01a4037716f9f490da5"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "./cmd/csprecon"
  end

  test do
    output = shell_output("#{bin}/csprecon -u https://brew.sh")
    assert_match "avatars.githubusercontent.com", output
  end
end
