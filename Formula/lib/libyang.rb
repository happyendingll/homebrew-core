class Libyang < Formula
  desc "YANG data modeling language library"
  homepage "https://github.com/CESNET/libyang"
  url "https://github.com/CESNET/libyang/archive/refs/tags/v6.4.13.tar.gz"
  sha256 "bf78a437225027ce9e20d2c449b7853204d7fd450bb00fb01e83339145561a86"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "700d8eee1f1d289a9dc25654d2e002d7c0e2d77baee5733570991254d31fdd9b"
  end

  depends_on "cmake" => :build
  depends_on "pcre2"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{lib}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # A small standalone module exercises basic schema parsing and tree output.
    (testpath/"homebrew-libyang-test.yang").write <<~YANG
      module homebrew-libyang-test {
        namespace "urn:homebrew:libyang:test";
        prefix hblt;

        container settings {
          leaf hostname {
            type string;
          }

          list interface {
            key "name";

            leaf name {
              type string;
            }

            leaf enabled {
              type boolean;
            }
          }
        }
      }
    YANG

    expected_tree = <<~TREE
      module: homebrew-libyang-test
        +--rw settings
           +--rw hostname?   string
           +--rw interface* [name]
              +--rw name       string
              +--rw enabled?   boolean
    TREE

    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <stdlib.h>
      #include <libyang/libyang.h>
      #include <libyang/parser_schema.h>
      #include <libyang/printer_schema.h>

      int main(int argc, char *argv[]) {
        struct ly_ctx *ctx = NULL;
        struct lys_module *module = NULL;
        char *tree = NULL;
        int ret = 1;

        if (argc != 2) {
          return 1;
        }

        if (ly_ctx_new(ly_yang_module_dir(), 0, &ctx) != LY_SUCCESS) {
          return 1;
        }

        if (lys_parse_path(ctx, argv[1], LYS_IN_YANG, &module) != LY_SUCCESS) {
          goto cleanup;
        }

        if (lys_print_mem(&tree, module, LYS_OUT_TREE, 0) != LY_SUCCESS) {
          goto cleanup;
        }

        fputs(tree, stdout);
        ret = 0;

      cleanup:
        free(tree);
        ly_ctx_destroy(ctx);
        return ret;
      }
    C

    # Compile and run a program that links libyang and renders the module tree.
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lyang", "-o", "test"
    assert_equal expected_tree, shell_output("./test homebrew-libyang-test.yang")

    # Check the installed CLI reports the formula version and renders the same tree.
    assert_match version.to_s, shell_output("#{bin}/yanglint --version")
    assert_equal expected_tree, shell_output("#{bin}/yanglint -f tree homebrew-libyang-test.yang")
  end
end
