class C2048 < Formula
  desc "Console version of 2048"
  homepage "https://github.com/mevdschee/2048.c"
  url "https://github.com/mevdschee/2048.c/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "83b9008dc77d7ab2ad721d7316551fb015dce97c40337a354040fe45d8296fd4"
  license "MIT"
  head "https://github.com/mevdschee/2048.c.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c338c1f582bb0b43260a59b3c7442509008ec496b408129d383d1385d86b89ea"
  end

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = shell_output("#{bin}/2048 test")
    assert_match "All 13 tests executed successfully", output
  end
end
