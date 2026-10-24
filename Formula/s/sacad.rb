class Sacad < Formula
  desc "Automatic cover art downloader"
  homepage "https://github.com/desbma/sacad"
  url "https://github.com/desbma/sacad/archive/refs/tags/3.0.4.tar.gz"
  sha256 "31780c419c4ca14310c8ac7023faf03ecb17a0098013f134af9fa750810d322b"
  license "MPL-2.0"
  head "https://github.com/desbma/sacad.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "11f47977aece364545fa7b11691cccd9fafe7144498a8208b663c17a1c20f5d0"
  end

  depends_on "rust" => :build

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sacad --version")
    system bin/"sacad", "metallica", "master of puppets", "600", "AlbumArt.jpg"
  end
end
