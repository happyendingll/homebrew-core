class Monolith < Formula
  desc "CLI tool for saving complete web pages as a single HTML file"
  homepage "https://github.com/Y2Z/monolith"
  url "https://github.com/Y2Z/monolith/archive/refs/tags/v2.12.0.tar.gz"
  sha256 "57e452913097c13614ef9c76d95264571a8580f30f6d4d52e6eea70437f6dbb8"
  license "CC0-1.0"
  head "https://github.com/Y2Z/monolith.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "0779f90eabf7f75a2d23075e0f4b6f23cabea93014126f81e03620c5806a7e20"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"monolith", "https://lyrics.github.io/db/P/Portishead/Dummy/Roads/"
  end
end
