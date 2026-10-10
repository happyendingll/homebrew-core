class Orbiton < Formula
  desc "Fast and config-free text editor and IDE limited by VT100"
  homepage "https://roboticoverlords.org/orbiton/"
  url "https://github.com/xyproto/orbiton/archive/refs/tags/v2.74.6.tar.gz"
  sha256 "c3eb0dec81895873f3d49e9f4c4a572b85e7a9f0ee697a934f3897ca876af1e0"
  license "BSD-3-Clause"
  head "https://github.com/xyproto/orbiton.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "09171d3cbf239ebcb3b6c6c5ef1cbab03fbf9c59bdaf93c035ee37eaf900cace"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "xorg-server" => :test
    depends_on "xclip"
  end

  deny_network_access!

  def install
    system "make", "install", "symlinks", "license", "DESTDIR=", "PREFIX=#{prefix}", "MANDIR=#{man}"
  end

  test do
    (testpath/"hello.txt").write "hello\n"
    copy_command = "#{bin}/o --copy #{testpath}/hello.txt"
    paste_command = "#{bin}/o --paste #{testpath}/hello2.txt"

    if OS.linux?
      system "xvfb-run", "sh", "-c", "#{copy_command} && #{paste_command}"
      assert_equal (testpath/"hello.txt").read, (testpath/"hello2.txt").read
    else
      # `--copy` and `--paste` need the pasteboard, which the test sandbox blocks
      assert_match "hello", shell_output("#{bin}/o --list #{testpath}/hello.txt")
    end
  end
end
