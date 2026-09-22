class Joyce < Formula
  desc "Emulates the Amstrad PCW on Unix, Windows and macOS"
  homepage "https://www.seasip.info/Unix/Joyce/index.html"
  url "https://www.seasip.info/Unix/Joyce/joyce-2.4.2.tar.gz"
  sha256 "85659a6ac9b94fdf78c28d5d8d65a4f69e7520e1c02a915b971c2754695ab82c"
  license "GPL-2.0-or-later"

  # Upstream indicates stable releases with an even-numbered minor (e.g., 1.2.3)
  # and the regex below only matches these versions as a way of avoiding the
  # development tarball on the download page.
  livecheck do
    url "https://www.seasip.info/Unix/Joyce/download.html"
    regex(/href=.*?joyce[._-]v?(\d+\.\d*[02468](?:\.\d+)*)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "b2b7453d2dc9d567403973fe2fac00a443477cc5c3724329a3a85c39f064bc77"
  end

  depends_on "libdsk"
  depends_on "libpng"
  depends_on "sdl12-compat"

  uses_from_macos "libxml2"

  def install
    # At the moment Joyces uses and bundles libdsk-1.5.x (dev)
    # while homebrew provides libdsk-1.4.x (stable) so we cannot
    # use the system's libdsk and we need to remove/not link
    # conflicting files.
    # system "./configure", "--disable-silent-rules", "--with-system-libdsk", *args
    args = %w[
      --disable-sdltest
      --disable-silent-rules
    ]
    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"

    # Remove conflicting files with bundled libdsk
    %w[apriboot dskdump dskform dskid dskscan dsktrans dskutil md3serial].each { |f| rm bin/f }
    rm lib/"libdsk.a"
  end

  test do
    assert_match "PCW / IBM 180k", shell_output("#{bin}/dskconv -formats")
    return if OS.mac? # unable to run xjoyce within macOS sandbox

    assert_match version.to_s, shell_output("#{bin}/xjoyce --version")

    output_log = testpath/"output.log"
    pid = spawn bin/"xjoyce", [:out, :err] => output_log.to_s
    begin
      sleep 2
      assert_match "JOYCE will emulate a PCW 82048 (or 92048)", output_log.read
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
