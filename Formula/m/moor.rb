class Moor < Formula
  desc "Nice to use pager for humans"
  homepage "https://github.com/walles/moor"
  url "https://github.com/walles/moor/archive/refs/tags/v2.19.1.tar.gz"
  sha256 "35e2f1bda3079b02f72d4c0b09a72f2687054d647d7502a0821b0ef8ee1ae417"
  license "BSD-2-Clause"
  head "https://github.com/walles/moor.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "9f2521980c8c7cf1caa0f0162bf10484ce1aef7959329944e38107df91103d7f"
  end

  depends_on "go" => :build

  conflicts_with "moarvm", "rakudo-star", because: "both install `moar` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.versionString=v#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/moor"

    # Hint for moar users to start typing "moor" instead
    bin.install "scripts/moar"

    man1.install "moor.1"
  end

  test do
    # Test piping text through moor
    (testpath/"test.txt").write <<~EOS
      tyre kicking
    EOS
    assert_equal "tyre kicking", shell_output("#{bin}/moor test.txt").strip
  end
end
