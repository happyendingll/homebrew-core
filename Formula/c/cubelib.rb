class Cubelib < Formula
  desc "Performance report explorer for Scalasca and Score-P"
  homepage "https://scalasca.org/cube/"
  url "https://apps.fz-juelich.de/scalasca/releases/cube/4.10/dist/cubelib-4.10.tar.gz"
  sha256 "ebdee61f2da04886430c4f8991fc1ef336c63a5409d122f71ccf1910851d0d4c"
  license "BSD-3-Clause"

  livecheck do
    url "https://scalasca.org/cube/download/"
    regex(/href=.*?cubelib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "7eb0d81fea6f0d11f60cdf927e71dfce6aa16cb97840aa2d9a4fe611917391fe"
  end

  depends_on "pkgconf" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    file "Patches/libtool/configure-big_sur.diff"
    directory "build-frontend"
  end

  deny_network_access!

  def install
    ENV.deparallelize

    args = %w[--disable-silent-rules]
    if ENV.compiler == :clang
      args << "--with-nocross-compiler-suite=clang"
      args << "CXXFLAGS=-stdlib=libc++"
      args << "LDFLAGS=-stdlib=libc++"
    end

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"

    inreplace pkgshare/"cubelib.summary", "#{Superenv.shims_path}/", ""
  end

  test do
    cp_r "#{share}/doc/cubelib/example/", testpath
    chdir "#{testpath}/example" do
      # build and run tests
      system "make", "-f", "Makefile.frontend", "all"
      system "make", "-f", "Makefile.frontend", "run"
    end
  end
end
