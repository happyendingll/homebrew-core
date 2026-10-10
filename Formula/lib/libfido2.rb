class Libfido2 < Formula
  desc "Provides library functionality for FIDO U2F & FIDO 2.0, including USB"
  homepage "https://developers.yubico.com/libfido2/"
  url "https://github.com/Yubico/libfido2/archive/refs/tags/1.17.0.tar.gz"
  sha256 "ace062d14a482ff9325410ff63d06c8b5fe87e79ebc18dda07add2bc0188c77f"
  license "BSD-2-Clause"
  revision 1
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "f85b9f80196515a93f0a047c4df4076a07fe88b49059e03249c04c1e1871344a"
  end

  depends_on "cmake" => :build
  depends_on "mandoc" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "libcbor"
  depends_on "openssl@4"

  on_linux do
    depends_on "systemd" # for libudev
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = OS.linux? ? ["-DUDEV_RULES_DIR=#{lib}/udev/rules.d"] : []

    system "cmake", "-S", ".", "-B", ".", *args, *std_cmake_args
    system "cmake", "--build", "."
    system "cmake", "--build", ".", "--target", "man_symlink_html"
    system "cmake", "--build", ".", "--target", "man_symlink"
    system "cmake", "--install", "."
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stddef.h>
      #include <stdio.h>
      #include <fido.h>

      int main(void) {
        fido_init(FIDO_DEBUG);
        // Attempt to enumerate up to five FIDO/U2F devices. Five is an arbitrary number.
        size_t max_devices = 5;
        fido_dev_info_t *devlist;
        if ((devlist = fido_dev_info_new(max_devices)) == NULL)
          return 1;
        size_t found_devices = 0;
        int error;
        if ((error = fido_dev_info_manifest(devlist, max_devices, &found_devices)) == FIDO_OK)
          printf("FIDO/U2F devices found: %s\\n", found_devices ? "Some" : "None");
        fido_dev_info_free(&devlist, max_devices);
      }
    C

    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("openssl@4")/"pkgconfig"
    flags = shell_output("pkgconf --cflags --libs libfido2").chomp.split
    system ENV.cc, "test.c", "-I#{include}", "-o", "test", *flags
    system "./test"
  end
end
