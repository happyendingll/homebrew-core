class Ffuf < Formula
  desc "Fast web fuzzer written in Go"
  homepage "https://github.com/ffuf/ffuf"
  url "https://github.com/ffuf/ffuf/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "cdb2e58259f380862850eba587f71a9dc1738fb5edc1ea60414fae30fd0ed4f2"
  license "MIT"
  head "https://github.com/ffuf/ffuf.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "8384fdf029e64406a17933a8c6bc2bf5caaf0699e0b5f40792e6abe4213ebe8b"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    (testpath/"words.txt").write <<~EOS
      dog
      cat
      horse
      snake
      ape
    EOS

    output = shell_output("#{bin}/ffuf -noninteractive -u https://example.org/FUZZ -w words.txt 2>&1")
    assert_match %r{:: Progress: \[5/5\].*Errors: 0 ::$}, output
  end
end
