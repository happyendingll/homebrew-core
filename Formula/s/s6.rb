class S6 < Formula
  desc "Small & secure supervision software suite"
  homepage "https://skarnet.org/software/s6/"
  url "https://skarnet.org/software/s6/s6-2.15.1.1.tar.gz"
  sha256 "62080839eb5b04d51efd4ef6e7b43e29b5d0576efce9eb319ace32ea90c05931"
  license "ISC"
  head "git://git.skarnet.org/s6.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1424904c3dce505f5d56cdd35c947d499d56f6b95676641b8d0d5a55bc2849ec"
  end

  depends_on "pkgconf" => :build
  depends_on "execline"
  depends_on "skalibs"

  def install
    args = %W[
      --disable-silent-rules
      --enable-shared
      --enable-pkgconfig
      --with-pkgconfig=#{formula_opt_bin("pkgconf")}/pkg-config
      --with-sysdeps=#{formula_opt_lib("skalibs")}/skalibs/sysdeps
    ]
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"log").mkpath
    pipe_output("#{bin}/s6-log #{testpath}/log", "Test input\n", 0)
    assert_equal "Test input\n", File.read(testpath/"log/current")
  end
end
