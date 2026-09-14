class Ncmpcpp < Formula
  desc "Ncurses-based client for the Music Player Daemon"
  homepage "https://rybczak.net/ncmpcpp/"
  # note, homepage did not get updated to the latest release tag in github
  url "https://github.com/ncmpcpp/ncmpcpp/archive/refs/tags/0.10.1.tar.gz"
  sha256 "ddc89da86595d272282ae8726cc7913867b9517eec6e765e66e6da860b58e2f9"
  license "GPL-2.0-or-later"
  revision 8
  head "https://github.com/ncmpcpp/ncmpcpp.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "7efa1537fdaca6efc1041a7c802df0952be81ae53598dc77ad032e5bbac7dcfe"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "boost"
  depends_on "fftw"
  depends_on "icu4c@78"
  depends_on "libmpdclient"
  depends_on "ncurses"
  depends_on "readline"
  depends_on "taglib"

  uses_from_macos "curl"

  # Backport fix for build with Boost 1.89.0
  patch do
    url "https://github.com/ncmpcpp/ncmpcpp/commit/f67d350aa9beb2abdd12c429e97ae919e5b3102c.patch?full_index=1"
    sha256 "7fa67adf722fec69793f9aa53398195294402bb09519e7bd99b388b7f99a5e59"
    type :backport
    resolves "https://github.com/ncmpcpp/ncmpcpp/pull/636",
             "https://github.com/ncmpcpp/ncmpcpp/issues/633"
  end

  # Fix build with libc++ 22
  patch do
    url "https://github.com/ncmpcpp/ncmpcpp/commit/7523f11583279a80c1578d29d6c189fa74f4aa64.patch?full_index=1"
    sha256 "684cd051e7a8a5954d2763c699482fa25b8d5b0b90e2329b02bb9dd48a1e31de"
    type :unofficial
    resolves "https://github.com/ncmpcpp/ncmpcpp/pull/665",
             "https://github.com/ncmpcpp/ncmpcpp/issues/663"
  end

  def install
    ENV.append "LDFLAGS", "-liconv" if OS.mac?
    ENV.prepend "LDFLAGS", "-L#{formula_opt_lib("readline")}"
    ENV.prepend "CPPFLAGS", "-I#{formula_opt_include("readline")}"
    ENV.append "CXXFLAGS", "-D_XOPEN_SOURCE_EXTENDED"

    args = %w[
      --disable-silent-rules
      --enable-clock
      --enable-outputs
      --enable-visualizer
      --with-taglib
    ]

    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    ENV.delete("LC_CTYPE")
    assert_match version.to_s, shell_output("#{bin}/ncmpcpp --version")
  end
end
