class Orbiton < Formula
  desc "Fast and config-free text editor and IDE limited by VT100"
  homepage "https://roboticoverlords.org/orbiton/"
  url "https://github.com/xyproto/orbiton/archive/refs/tags/v2.75.0.tar.gz"
  sha256 "12fcbe320917f41c389146ece50e9627554da4023e15cf01a1516cc90ec19b29"
  license "BSD-3-Clause"
  head "https://github.com/xyproto/orbiton.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "401d453a717c3f792bbacae5afbcac77d11eb32d495f7b360a27b35d9348424e"
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
