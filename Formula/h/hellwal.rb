class Hellwal < Formula
  desc "Fast, extensible color palette generator"
  homepage "https://github.com/danihek/hellwal"
  url "https://github.com/danihek/hellwal/archive/refs/tags/1.0.8.tar.gz"
  sha256 "53f629f22bd80c95150fa8510c4c5f4969beec06bfd01ad33a5fdad3d56a357e"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "19395ae45b6b84e7bdcccb554b2d76abc7c9b5826632759258b8760445514426"
  end

  def install
    system "make", "install", "DESTDIR=#{bin}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hellwal --version")

    (testpath/"hw.theme").write "%% color0  = #282828 %%"
    output = shell_output("#{bin}/hellwal --skip-term-colors -j -t hw.theme 2>&1", 1)
    assert_match "Not enough colors were specified in color palette", output
  end
end
