class Chuck < Formula
  desc "Concurrent, on-the-fly audio programming language"
  homepage "https://chuck.cs.princeton.edu/"
  url "https://chuck.cs.princeton.edu/release/files/chuck-1.5.5.9.tgz"
  mirror "https://chuck.stanford.edu/release/files/chuck-1.5.5.9.tgz"
  sha256 "b3e9f3e752d2c7a8d3eb9f359c70fc624de12a2278b3facdffb902439fa3943c"
  license "GPL-2.0-or-later"
  head "https://github.com/ccrma/chuck.git", branch: "main"

  livecheck do
    url "https://chuck.cs.princeton.edu/release/files/"
    regex(/href=.*?chuck[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c1125bb4817f2ec7cbb68818031cf269acca21654ac60ce3d21592696716e9d6"
  end

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_linux do
    depends_on "alsa-lib"
    depends_on "libsndfile"
    depends_on "pulseaudio"
  end

  def install
    os = OS.mac? ? "mac" : "linux-pulse"
    system "make", "-C", "src", os
    bin.install "src/chuck"
    pkgshare.install "examples"
  end

  test do
    (testpath/"test.ck").write("<<< 2 + 3 >>>;\n")
    assert_match "5 :(int)", shell_output("#{bin}/chuck --silent #{testpath}/test.ck 2>&1")
  end
end
