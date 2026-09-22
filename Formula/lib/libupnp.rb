class Libupnp < Formula
  desc "Portable UPnP development kit"
  homepage "https://pupnp.sourceforge.io/"
  url "https://github.com/pupnp/pupnp/releases/download/release-22.1.1/libupnp-22.1.1.tar.bz2"
  sha256 "7d161e48cd8a33a8e6c08725734add9aa40a86c07c9606ff6c68435226a842a8"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^release[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "4ed830aff3999e05616b62b76e40a9051fe6203ebd8cc26c784030648af4fa7e"
    sha256 cellar: :any, arm64_tahoe:       "455645b4090845dcff43c83e343e6b97a072546cef29f128b71384190ed2cee0"
    sha256 cellar: :any, arm64_sequoia:     "b7bc0c57e90ff3cea8715305337f2e474fffd4fe337d74d9177101a334aaec12"
    sha256 cellar: :any, arm64_linux:       "a3be6c6b015b84e02c83caa6b7c719528e1bbb509573571e1b18317913c74965"
    sha256 cellar: :any, x86_64_linux:      "3740cd2e046b6a5709855ef650af7333ff6a560fe9daec02af1f052ac65f9214"
  end

  depends_on "cmake" => :build

  def install
    # https://github.com/llvm/llvm-project/issues/65557
    if OS.mac? && DevelopmentTools.clang_build_version < 1700
      inreplace "upnp/src/genlib/miniserver/miniserver.c", "switch (gMServState)",
                                                           "switch ((MiniServerState)gMServState)"
    end

    system "cmake", "-S", ".", "-B", "build",
                    "-DUPNP_BUILD_SAMPLES=OFF",
                    "-DUPNP_ENABLE_TESTING=OFF",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <upnp.h>
      #include <upnpconfig.h>
      #include <stdio.h>
      int main(void) {
        printf("UPNP_VERSION_STRING = \\"%s\\"\\n", UPNP_VERSION_STRING);
        int rc = UpnpInit2(NULL, 0);
        if (rc == UPNP_E_SUCCESS) {
          printf("UPnP Initialized OK\\n");
          UpnpFinish();
        }
        return rc;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}/upnp", "-L#{lib}", "-lupnp"
    output = shell_output("./test")
    assert_match "UPNP_VERSION_STRING = \"#{version}\"", output
    assert_match "UPnP Initialized OK", output
  end
end
