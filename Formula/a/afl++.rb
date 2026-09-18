class Aflxx < Formula
  desc "American Fuzzy Lop++"
  homepage "https://aflplus.plus/"
  url "https://github.com/AFLplusplus/AFLplusplus/archive/refs/tags/v5.03c.tar.gz"
  version "5.03c"
  sha256 "07f089e8591209862898c770a569d8e2b74b459fe967db323fc6a3924dcc82b5"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+c)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "64e56be146388d640e8682123369171266aa34a8c6045ce9fa4dfded87ccdf53"
  end

  depends_on "coreutils" => :build
  depends_on "lld"
  depends_on "llvm"
  depends_on "python@3.14"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # The Makefile will insist on compiling with LLVM clang even without this.
  fails_with :clang
  fails_with :gcc

  deny_network_access!

  def install
    ENV.prepend_path "PATH", formula_opt_libexec("coreutils")/"gnubin"

    if OS.mac?
      # Disable the in-build test runs as they require modifying system settings as root.
      inreplace ["GNUmakefile", "GNUmakefile.llvm"] do |f|
        f.gsub! "all_done: test_build", "all_done:"
        f.gsub! " test_build all_done", " all_done"
      end
    end

    llvm = Formula["llvm"]
    make_args = %W[
      PREFIX=#{prefix}
      CC=clang
      CXX=clang++
      LLVM_BINDIR=#{llvm.opt_bin}
      LLVM_LIBDIR=#{llvm.opt_lib}
    ]

    system "make", "source-only", *make_args
    system "make", "install", *make_args
    return unless llvm.keg_only?

    bin.env_script_all_files libexec, PATH: "#{llvm.opt_bin}:${PATH}"
  end

  test do
    cpp_file = testpath/"main.cpp"
    cpp_file.write <<~CPP
      #include <iostream>

      int main() {
        std::cout << "Hello, world!";
      }
    CPP

    system bin/"afl-c++", "-g", cpp_file, "-o", "test"
    assert_equal "Hello, world!", shell_output("./test")
  end
end
