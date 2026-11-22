class Ncmpc < Formula
  desc "Curses Music Player Daemon (MPD) client"
  homepage "https://www.musicpd.org/clients/ncmpc/"
  url "https://www.musicpd.org/download/ncmpc/0/ncmpc-0.55.tar.xz"
  sha256 "9b332932306e210f28b27f65b368a1ebf9270410c2ea9ac0d620d46f2a5379a8"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.musicpd.org/download/ncmpc/0/"
    regex(/href=.*?ncmpc[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1408d0385a44d4cc5f473e830935dca7aa25f9c52fedbf0af877538125c71569"
  end

  depends_on "boost" => :build
  depends_on "gettext" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "fmt"
  depends_on "libmpdclient"
  depends_on "pcre2"

  uses_from_macos "ncurses"

  on_macos do
    depends_on "gettext"
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1500

    # Fixes: error: use of undeclared identifier 'strcoll_l'
    patch do
      url "https://github.com/MusicPlayerDaemon/ncmpc/commit/af478b5ba2447592c640c5b7f86c47d9a412c639.patch?full_index=1"
      sha256 "193f6c3192ba39974a2f1ef4935c623d58e0614f9978b2e6545c6231fd5ffdb5"
      type :unofficial
      resolves "https://github.com/MusicPlayerDaemon/ncmpc/pull/160"
    end
  end

  fails_with :clang do
    build 1500
    cause "Requires C++20"
  end

  fails_with :gcc do
    version "9"
    cause "Requires C++20"
  end

  def install
    # Apple Clang 16 rejects `constexpr` with `reinterpret_cast` (P2448 needs LLVM 17), e.g. GetSteadyPart()
    ENV.append "CXXFLAGS", "-Wno-invalid-constexpr" if OS.mac? && DevelopmentTools.clang_build_version < 1700

    system "meson", "setup", "build", "-Dcolors=false", "-Dnls=enabled", "-Dregex=enabled", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match "Key configuration screen", shell_output("#{bin}/ncmpc --dump-keys")
    assert_match version.to_s, shell_output("#{bin}/ncmpc --version")
  end
end
