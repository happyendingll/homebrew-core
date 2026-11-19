class Libnfs < Formula
  desc "C client library for NFS"
  homepage "https://github.com/sahlberg/libnfs"
  url "https://github.com/sahlberg/libnfs/archive/refs/tags/libnfs-8.0.1.tar.gz"
  sha256 "03653086471ceddd846077151adc6fda9ebc47118010a196e27f4f2e3e5e32f0"
  license "LGPL-2.1-or-later"
  compatibility_version 5

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "103e72045b6dddd00e3295cb0d205be0c17c58d970415da97c705b2043583d82"
  end

  depends_on "cmake" => :build
  depends_on "docbook" => :build
  depends_on "docbook-xsl" => :build

  deny_network_access!

  def install
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "cmake", "-S", ".", "-B", "build", "-DENABLE_DOCUMENTATION=ON", "-DENABLE_UTILS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "No URL specified", shell_output("#{bin}/nfs-ls 2>&1", 1)

    (testpath/"test.c").write <<~C
      #if defined(__linux__)
      # include <sys/time.h>
      #endif
      #include <stddef.h>
      #include <nfsc/libnfs.h>

      int main(void)
      {
        int result = 1;
        struct nfs_context *nfs = NULL;
        nfs = nfs_init_context();

        if (nfs != NULL) {
            result = 0;
            nfs_destroy_context(nfs);
        }

        return result;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lnfs", "-o", "test"
    system "./test"
  end
end
