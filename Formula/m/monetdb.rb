class Monetdb < Formula
  desc "Column-store database"
  homepage "https://www.monetdb.org/"
  url "https://www.monetdb.org/downloads/sources/Dec2025-SP4/MonetDB-11.55.9.tar.xz"
  sha256 "c2edb5a930fc0c5aaf7fe1cac34be2bb125a1e52ee5fbdf1df9a993cc526cffe"
  license "MPL-2.0"
  head "https://www.monetdb.org/hg/MonetDB", using: :hg

  livecheck do
    url "https://www.monetdb.org/downloads/sources/archive/"
    regex(/href=.*?MonetDB[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "50956a9a128ebeec2db0346d12a652c6f936c53ec3c9452d2e2f59165bfa47eb"
  end

  depends_on "bison" => :build # macOS bison is too old
  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "lz4"
  depends_on "openssl@4"
  depends_on "pcre2"
  depends_on "readline" # Compilation fails with libedit
  depends_on "xz"

  uses_from_macos "python" => :build
  uses_from_macos "bzip2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = %w[
      -DRELEASE_VERSION=ON
      -DASSERT=OFF
      -DSTRICT=OFF
      -DTESTING=OFF
      -DFITS=OFF
      -DGEOM=OFF
      -DNETCDF=OFF
      -DODBC=OFF
      -DPY3INTEGRATION=OFF
      -DRINTEGRATION=OFF
      -DSHP=OFF
      -DWITH_BZ2=ON
      -DWITH_CMOCKA=OFF
      -DWITH_CURL=ON
      -DWITH_LZ4=ON
      -DWITH_LZMA=ON
      -DWITH_OPENSSL=ON
      -DWITH_PCRE=ON
      -DWITH_PROJ=OFF
      -DWITH_RTREE=OFF
      -DWITH_SQLPARSE=OFF
      -DWITH_VALGRIND=OFF
      -DWITH_XML2=ON
      -DWITH_ZLIB=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    # remove reference to shims directory from compilation/linking info
    inreplace "build/tools/mserver/monet_version.c", %r{"/[^ ]*/}, "\""
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # assert_match "Usage", shell_output("#{bin}/mclient --help 2>&1")
    system bin/"monetdbd", "create", testpath/"dbfarm"
    assert_path_exists testpath/"dbfarm"
  end
end
