class Unixcw < Formula
  desc "Morse code tutor and command-line tools"
  homepage "https://unixcw.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/unixcw/unixcw-3.6.1.tar.gz"
  sha256 "0af83855214bf90b4c0d149221884ab4458f3857c38972d428daebf3badd6e32"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "b555c0b1ba39fdac344aaa42e0bbe62918e25a519b826b10286e15b40003b36d"
  end

  depends_on "pkgconf" => :build

  depends_on "gettext"
  depends_on "pulseaudio"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "alsa-lib"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    file "Patches/libtool/configure-big_sur.diff"
    type :unofficial
  end

  deny_network_access!

  def install
    # Load PulseAudio by absolute path and use a clock that exists on macOS.
    # Both changes submitted upstream: https://sourceforge.net/p/unixcw/tickets/3/
    inreplace "src/libcw/libcw_pa.c", '"libpulse-simple.so.0"',
              "\"#{formula_opt_lib("pulseaudio")/shared_library("libpulse-simple", 0)}\""
    ENV.append_to_cflags "-DCLOCK_BOOTTIME=CLOCK_MONOTONIC" if OS.mac?

    system "./configure", "--disable-xcwcp", "--disable-static", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "cw version #{version}", shell_output("#{bin}/cw --version 2>&1")
    assert_match "cwgen version #{version}", shell_output("#{bin}/cwgen --version 2>&1")
    assert_match "cwcp version #{version}", shell_output("#{bin}/cwcp --version 2>&1")

    # cwgen: output should be different on each invocation
    out1 = shell_output("#{bin}/cwgen")
    out2 = shell_output("#{bin}/cwgen")
    assert_match(/\A(?:[A-Z0-9]{5}\s*)+\z/, out1)
    refute_equal out1, out2

    # cw: output should match input
    assert_equal "hello brew\n", pipe_output("#{bin}/cw --system=null --wpm=60", "hello brew\n", 0)
  end
end
