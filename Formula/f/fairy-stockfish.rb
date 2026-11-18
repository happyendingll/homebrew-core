class FairyStockfish < Formula
  desc "Strong open source chess variant engine (with largeboards support)"
  homepage "https://fairy-stockfish.github.io/"
  url "https://github.com/fairy-stockfish/Fairy-Stockfish/archive/refs/tags/fairy_sf_14_0_1_xq.tar.gz"
  version "14.0.1"
  sha256 "53914fc89d89afca7cfcfd20660ccdda125f1751f59a68b1f3ed1d4eb6cfe805"
  license "GPL-3.0-or-later"
  head "https://github.com/fairy-stockfish/Fairy-Stockfish.git", branch: "master"

  livecheck do
    url :stable
    regex(/^fairy_sf[._-]v?(\d+(?:[._-]\d+)*)(?:_xq)?$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag.match(regex)&.[](1)&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7cc4363b237ad9b7c4d086651302dc0854e5b723d5e9127fe945015bcec63d33"
  end

  deny_network_access!

  def install
    arch = if Hardware::CPU.arm?
      if OS.mac?
        "apple-silicon"
      else
        "armv8"
      end
    elsif build.bottle?
      "x86-64-ssse3"
    elsif Hardware::CPU.avx2?
      "x86-64-avx2"
    elsif Hardware::CPU.sse4?
      "x86-64-sse41-popcnt"
    elsif Hardware::CPU.ssse3?
      "x86-64-ssse3"
    else
      "x86-64"
    end

    args = %W[
      PREFIX=#{prefix}
      EXE=fairy-stockfish
      ARCH=#{arch}
      COMPCXX=#{ENV.cxx}
    ]

    system "make", "-C", "src", "profile-build", "largeboards=yes", *args
    system "make", "-C", "src", "install", *args
  end

  test do
    system bin/"fairy-stockfish", "go", "depth", "20"
  end
end
