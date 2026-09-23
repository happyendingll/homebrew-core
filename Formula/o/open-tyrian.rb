class OpenTyrian < Formula
  desc "Open-source port of Tyrian"
  homepage "https://github.com/opentyrian/opentyrian"
  url "https://github.com/opentyrian/opentyrian/archive/refs/tags/v2.1.20260913.tar.gz"
  sha256 "dbcd96383d4fa571137242c36bd7eca054cf5a08a9bf2eec15ef230d6e60680d"
  license "GPL-2.0-or-later"
  head "https://github.com/opentyrian/opentyrian.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "7f01a9b29a5ad1cf5ad6f2f1f52ae1cf1d4cd6e8480cf815ceb0e0ff15bc388f"
  end

  depends_on "pkgconf" => :build
  depends_on "sdl2-compat"
  depends_on "sdl2_net"

  resource "homebrew-test-data" do
    url "https://www.camanis.net/tyrian/tyrian21.zip"
    sha256 "7790d09a2a3addcd33c66ef063d5900eb81cc9c342f4807eb8356364dd1d9277"
  end

  def install
    datadir = pkgshare/"data"
    datadir.install resource("homebrew-test-data")
    system "make", "TYRIAN_DIR=#{datadir}"
    bin.install "opentyrian"
  end

  def caveats
    "Save games will be put in ~/.opentyrian"
  end

  test do
    system bin/"opentyrian", "--help"
  end
end
