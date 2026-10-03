class Faad2 < Formula
  desc "ISO AAC audio decoder"
  homepage "https://freewareadvancedaudio.github.io"
  url "https://github.com/FreewareAdvancedAudio/faad2/archive/refs/tags/2.11.4.tar.gz"
  sha256 "ee479ccbae4a8387ab696e6f21a481bd83fe3881471cafa81b4ae59d7d3aed43"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "e5d88145413b4412fa346c689abeb74465456147e280d26a268b13c19003a475"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    output = shell_output("#{bin}/faad -i #{test_fixtures("test.m4a")} 2>&1")
    assert_match "LC AAC\t0.192 secs, 1 ch, 8000 Hz", output
  end
end
