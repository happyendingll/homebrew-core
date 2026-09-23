class Openrtsp < Formula
  desc "Command-line RTSP client"
  homepage "http://www.live555.com/openRTSP"
  url "https://download.live555.com/live.2026.09.23.tar.gz"
  mirror "https://download.videolan.org/pub/videolan/testing/contrib/live555/live.2026.09.23.tar.gz"
  mirror "https://pkg.freebsd.org/ports-distfiles/live.2026.09.23.tar.gz"
  # Keep a mirror as upstream tarballs are removed after each version
  sha256 "22da8a0e12219f049051052317ff3774eaae888e6f94fd7be746bc236ad0d7eb"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://download.live555.com/"
    regex(/href=.*?live[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "8c48238ef5e9f9728a0619b8294a5f56d905928940c827979ca6d56fc1370d23"
    sha256 cellar: :any, arm64_tahoe:       "cd73adae6df4013d3c68dc112a6094bdd7d88bd5a31b63a00973524a7802969a"
    sha256 cellar: :any, arm64_sequoia:     "43550e7092b2e4831162df5550da740490d90b1720420b4afd59e38cfa0d7ee2"
    sha256 cellar: :any, arm64_linux:       "42449e6df557187a9658180566d55ac163c5935e3df7f28ad2f6b6812031de03"
    sha256 cellar: :any, x86_64_linux:      "816cfb29bb29f67a064c70d2c4defba3b2aa35cbb66105859673a0a6f03eaa68"
  end

  depends_on "openssl@3"

  def install
    # "test" was added to std::atomic_flag in C++20
    # See https://github.com/rgaufman/live555/issues/45
    ENV.append "CXXFLAGS", "-std=c++20"

    # Avoid linkage to system OpenSSL
    libs = [
      formula_opt_lib("openssl@3")/shared_library("libcrypto"),
      formula_opt_lib("openssl@3")/shared_library("libssl"),
    ]

    os_flag = OS.mac? ? "macosx-bigsur" : "linux"
    system "./genMakefiles", os_flag
    system "make", "PREFIX=#{prefix}",
           "LIBS_FOR_CONSOLE_APPLICATION=#{libs.join(" ")}", "install"

    # Move the testing executables out of the main PATH
    libexec.install Dir.glob(bin/"test*")
  end

  def caveats
    <<~EOS
      Testing executables have been placed in:
        #{libexec}
    EOS
  end

  test do
    assert_match "GNU", shell_output("#{bin}/live555ProxyServer 2>&1", 1)
  end
end
