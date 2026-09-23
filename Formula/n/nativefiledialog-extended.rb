class NativefiledialogExtended < Formula
  desc "Native file dialog library with C and C++ bindings"
  homepage "https://github.com/btzy/nativefiledialog-extended"
  url "https://github.com/btzy/nativefiledialog-extended/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "38116050495cd7de77a91d6d8d59c1aa0a0848c56daa60029bd5b59f3c897229"
  license "Zlib"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "64824d17a4f3f8466245c7b49e6226b9aa3e50b1a884508bfff2a486d3a26009"
  end

  depends_on "cmake" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "wayland-protocols" => :build
    depends_on "glib"
    depends_on "gtk+3"
    depends_on "wayland"
  end

  deny_network_access!

  def install
    if OS.linux?
      # Use our `wayland-protocols` as the tarball lacks the `3ps/wayland-protocols` submodule
      rmdir "3ps/wayland-protocols"
      ln_s Formula["wayland-protocols"].opt_pkgshare, "3ps/wayland-protocols"
    end

    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DNFD_BUILD_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <nfd.h>
      #include <stdio.h>
      #include <stdlib.h>

      int main(void) {
        NFD_Init();

        nfdu8char_t *outPath;
        nfdu8filteritem_t filters[2] = { { "Source code", "c,cpp,cc" }, { "Headers", "h,hpp" } };
        nfdopendialogu8args_t args = {0};
        args.filterList = filters;
        args.filterCount = 2;

        NFD_Quit();
        return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-lnfd"
    system "./test"
  end
end
