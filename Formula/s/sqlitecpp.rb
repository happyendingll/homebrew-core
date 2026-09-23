class Sqlitecpp < Formula
  desc "Smart and easy to use C++ SQLite3 wrapper"
  homepage "https://srombauts.github.io/SQLiteCpp/"
  url "https://github.com/SRombauts/SQLiteCpp/archive/refs/tags/3.4.0.tar.gz"
  sha256 "9910ad8bc0a821856bd6d9fa7cb0b457883108f2b803700256b451077ed6dc05"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "f4e930dcd186b9b328d795c4fcf0eea61fab65b4df241be5c6810eb366acdefd"
  end

  depends_on "cmake" => :build
  depends_on "sqlite" # needs sqlite3_load_extension

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DSQLITECPP_INTERNAL_SQLITE=OFF",
                    "-DSQLITECPP_RUN_CPPLINT=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"example").install "examples/example2/src/main.cpp"
  end

  test do
    system ENV.cxx, "-std=c++11", pkgshare/"example/main.cpp", "-o", "test", "-L#{lib}", "-lSQLiteCpp"
    system "./test"
  end
end
