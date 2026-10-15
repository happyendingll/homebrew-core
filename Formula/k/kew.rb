class Kew < Formula
  desc "Command-line music player"
  homepage "https://github.com/ravachol/kew"
  url "https://github.com/ravachol/kew/archive/refs/tags/v4.4.1.tar.gz"
  sha256 "b4a534501a4ce8813a8e9b06a87ce313af6cc53bb231c88c38c0d6b1a70358c5"
  license "GPL-2.0-or-later"
  head "https://github.com/ravachol/kew.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "acc1d256bdf5e9af052d29fa1ca43c1882634b42f14e3d82b4f17d2e0c0cb0d3"
  end

  depends_on "pkgconf" => :build
  depends_on "chafa"
  depends_on "faad2"
  depends_on "fftw"
  depends_on "glib"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "opus"
  depends_on "opusfile"
  depends_on "taglib"

  uses_from_macos "curl"

  on_macos do
    depends_on "gdk-pixbuf"
    depends_on "gettext"
  end

  on_linux do
    depends_on "libnotify"
  end

  deny_network_access!

  def install
    system "make", "install", "PREFIX=#{prefix}", "LANGDIRPREFIX=#{prefix}"
    man1.install "docs/kew.1"
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath/".config"
    ENV["XDG_STATE_HOME"] = testpath/".local/state"

    (testpath/".config/kew").mkpath
    (testpath/".local/state").mkpath
    (testpath/".config/kew/kewrc").write ""

    system bin/"kew", "path", testpath

    # `kew` puts the terminal in raw mode, so it needs to own a PTY to avoid `SIGTTOU`
    output = ""
    PTY.spawn(bin/"kew", "song") do |r, _w, _pid|
      r.winsize = [40, 120]
      begin
        r.each_line { |line| output += line }
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end
    assert_match "No Music found.", output
    assert_match "Please make sure the path is set correctly", output

    assert_match version.to_s, shell_output("#{bin}/kew --version")
  end
end
