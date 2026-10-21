class Sacad < Formula
  desc "Automatic cover art downloader"
  homepage "https://github.com/desbma/sacad"
  url "https://github.com/desbma/sacad/archive/refs/tags/3.0.3.tar.gz"
  sha256 "747a2b3847c85ad55f4b8ef53b9a133003c53ad9e3c644e74ed762756b613748"
  license "MPL-2.0"
  head "https://github.com/desbma/sacad.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b6ee31dfb64bd464eac2f3fd735f59f357f5ceb3695b23dbc5b6f87e4a6d8abe"
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
