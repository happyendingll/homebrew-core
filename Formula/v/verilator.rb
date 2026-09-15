class Verilator < Formula
  desc "Verilog simulator"
  homepage "https://www.veripool.org/wiki/verilator"
  url "https://github.com/verilator/verilator/archive/refs/tags/v5.052.tar.gz"
  sha256 "8c8d2e11e6ad32f641dd250742a94195ddecb912e2e2dabe2f42ddbbb99c1092"
  license any_of: ["LGPL-3.0-only", "Artistic-2.0"]
  head "https://github.com/verilator/verilator.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "e83600c7abedb7605f3f3f9b63179c670562e5c654c29e21b57a9cef9e3c0b9f"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  # macOS 27's system flex emits `yy_create_buffer(FILE *, yy_size_t)`, mismatching `src/V3PreLex.h`
  depends_on "flex" => :build
  depends_on "help2man" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "perl"
  uses_from_macos "python"

  skip_clean "bin" # Allows perl scripts to keep their executable flag

  def install
    # FIXME: Homebrew flex's `FlexLexer.h` keeps `int` signatures; skip flexfix's `size_t` rewrite for Apple's header
    inreplace "src/flexfix", 'platform.system() == "Darwin"', "False"
    system "autoconf"
    system "./configure", "--prefix=#{prefix}"
    ENV.deparallelize if OS.mac?
    # `make` and `make install` need to be separate for parallel builds
    system "make"
    system "make", "install"

    # Avoid hardcoding build-time references that may not be valid at runtime.
    inreplace pkgshare/"include/verilated.mk" do |s|
      s.change_make_var! "CXX", "c++"
      s.change_make_var! "LINK", "c++"
      s.change_make_var! "PERL", "perl"
      s.change_make_var! "PYTHON3", "python3"
    end
  end

  test do
    (testpath/"test.v").write <<~VERILOG
      module test;
         initial begin $display("Hello World"); $finish; end
      endmodule
    VERILOG
    (testpath/"test.cpp").write <<~CPP
      #include "Vtest.h"
      #include "verilated.h"
      int main(int argc, char **argv, char **env) {
          Verilated::commandArgs(argc, argv);
          Vtest* top = new Vtest;
          while (!Verilated::gotFinish()) { top->eval(); }
          delete top;
          exit(0);
      }
    CPP
    system bin/"verilator", "-Wall", "--cc", "test.v", "--exe", "test.cpp"
    cd "obj_dir" do
      system "make", "-j", "-f", "Vtest.mk", "Vtest"
      expected = <<~EOS
        Hello World
        - test.v:2: Verilog $finish
      EOS
      assert_equal expected, shell_output("./Vtest")
    end
  end
end
