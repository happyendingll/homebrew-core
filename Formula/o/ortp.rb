class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://linphone.org/"
  url "https://gitlab.linphone.org/BC/public/linphone-sdk/-/archive/5.5.26/linphone-sdk-5.5.26.tar.bz2"
  sha256 "df9e3aae15eb79912b91e5ee9d713e043ddbe9f38b70ae95ad3cd72fe29c0d16"
  license all_of: ["AGPL-3.0-or-later", "GPL-3.0-or-later"]
  head "https://gitlab.linphone.org/BC/public/linphone-sdk.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "5b1f3a023bf6769606555b9f97c76e878e2c2a383b62fdd8be4909dd115786bb"
    sha256 cellar: :any, arm64_tahoe:       "148a711be04c2538001c6e41e42c83f0e193ab06b78d00f4552ee6ba4e7983f9"
    sha256 cellar: :any, arm64_sequoia:     "de66f7a6c2587fb68e6ebcb2db84a8907e6322213668a405ddf2f1b4273530b0"
    sha256 cellar: :any, arm64_linux:       "5c41b684038e3016eda2d7cad130dd7eb334ab8486fe87c637a0034d7fb3060b"
    sha256 cellar: :any, x86_64_linux:      "91d4716776740f71c426b0d268953d513a751331bc2ae594d25cb6040a9fb69a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_MBEDTLS=OFF
      -DENABLE_OPENSSL=ON
      -DENABLE_TESTS_COMPONENT=OFF
    ]

    system "cmake", "-S", "bctoolbox", "-B", "build_bctoolbox", *args, *std_cmake_args
    system "cmake", "--build", "build_bctoolbox"
    system "cmake", "--install", "build_bctoolbox"
    prefix.install "bctoolbox/LICENSE.txt" => "LICENSE-bctoolbox.txt"

    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_DOC=OFF
      -DENABLE_UNIT_TESTS=OFF
    ]
    args << "-DCMAKE_INSTALL_RPATH=#{frameworks}" if OS.mac?

    system "cmake", "-S", "ortp", "-B", "build_ortp", *args, *std_cmake_args
    system "cmake", "--build", "build_ortp"
    system "cmake", "--install", "build_ortp"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "ortp/logging.h"
      #include "ortp/rtpsession.h"
      #include "ortp/sessionset.h"
      int main()
      {
        ORTP_PUBLIC void ortp_init(void);
        return 0;
      }
    C
    linker_flags = OS.mac? ? %W[-F#{frameworks} -framework ortp] : %W[-L#{lib} -lortp]
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", *linker_flags
    system "./test"
  end
end
