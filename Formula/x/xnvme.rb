class Xnvme < Formula
  desc "Cross-platform libraries and tools for efficient I/O and low-level control"
  homepage "https://xnvme.io/"
  url "https://github.com/xnvme/xnvme/releases/download/v0.8.1/xnvme-fat-0.8.1.tar.gz"
  sha256 "3718417f4637949091815a77a3d4bf4512c9adedb5d0ca0886496e36a32fe8f8"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 sequoia: "09aa8aad8a7900f085fd305b78fd3a2bdecc3a2d489db41324145fd46a384e8d"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]

  deny_network_access!

  def install
    # We do not have SPDK nor libvfn on macOS, thus disabling these
    # The examples and tests are also a bit superfluous, so disable those as well
    args = %w[
      -Dwith-spdk=disabled
      -Dwith-libvfn=disabled
      -Dtests=false
      -Dexamples=false
    ]
    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    # Verify cli usage using a "ramdisk" of 1GB
    output = shell_output("#{bin}/xnvme info 1GB --be ramdisk")
    assert_match "uri: '1GB'", output
    assert_match "type: XNVME_GEO_CONVENTIONAL", output
    assert_match "tbytes: 1073741824", output

    # Verify library usage using a ramdisk of 1GB
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <libxnvme.h>

      int main(int argc, char **argv) {
        struct xnvme_opts opts = xnvme_opts_default();
        struct xnvme_dev *dev;

        dev = xnvme_dev_open("1GB", &opts);
        if (!dev) {
          perror("xnvme_dev_open()");
          return 1;
        }

        xnvme_dev_pr(dev, XNVME_PR_DEF);
        xnvme_dev_close(dev);

        return 0;
      }
    C

    # Build the example using pkg-config for build-options
    flags = shell_output("pkg-config xnvme --libs --cflags").strip
    system ENV.cc, "test.c", "-o", "test", *flags.split

    # Run it and check the output, this should produce the same output as the
    # 'xnvme library-info' command, thus the output-assertion is the same
    output = shell_output("./test info 1GB --be ramdisk")
    assert_match "uri: '1GB'", output
    assert_match "type: XNVME_GEO_UNKNOWN", output
    assert_match "tbytes: 0", output
  end
end
