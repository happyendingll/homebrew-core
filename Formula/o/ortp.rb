class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://linphone.org/"
  url "https://gitlab.linphone.org/BC/public/linphone-sdk/-/archive/5.5.24/linphone-sdk-5.5.24.tar.bz2"
  sha256 "44922b7016e5bd00eb7b92405c4c090052114d4b402e60c586d19ddea5a0b2b0"
  license all_of: ["AGPL-3.0-or-later", "GPL-3.0-or-later"]
  head "https://gitlab.linphone.org/BC/public/linphone-sdk.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "4938509a94c084dcc0c7fe9f9d05fea38d3a8a40848dacbed052d67c34ba8ef2"
    sha256 cellar: :any, arm64_tahoe:       "091ab1aab710b0ed44132efae489a9ac5c09eb6728781820db24da55fab9951f"
    sha256 cellar: :any, arm64_sequoia:     "3305f4ded608fecbe40a21ec7f3a6fa2429a3fbf2759dd867483dc56b03fae53"
    sha256 cellar: :any, arm64_linux:       "70c761a23164d7fcd3ee7be662d0b32749b5ddad214f8b249edd4fe0ee441ae4"
    sha256 cellar: :any, x86_64_linux:      "6293536df9987935003816632a339cb508ab053066db6d9163d8e41388642aae"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@3" # OpenSSL 4 is not supported in monorepo

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
