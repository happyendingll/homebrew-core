class Openrtsp < Formula
  desc "Command-line RTSP client"
  homepage "http://www.live555.com/openRTSP"
  url "https://download.live555.com/live.2026.10.21.tar.gz"
  mirror "https://download.videolan.org/pub/videolan/testing/contrib/live555/live.2026.10.21.tar.gz"
  mirror "https://pkg.freebsd.org/ports-distfiles/live.2026.10.21.tar.gz"
  # Keep a mirror as upstream tarballs are removed after each version
  sha256 "f7da1a6647021a3cade66335ed55ac61ff4e764947bc587b069cb64b2f9ec949"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://download.live555.com/"
    regex(/href=.*?live[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "81dc4ec37e21cc26ae878ec0aff92551e1730a99d0520163626191fe5ae46d1f"
    sha256 cellar: :any, arm64_tahoe:       "a59854ec29bb0aa72dd0d94dd4a967b58f1f64dd7f7947f6e6b16d5e3cb6d13c"
    sha256 cellar: :any, arm64_sequoia:     "1d559c675f91b00868ded1edaacb8ecfba864e33a03b861ccf1abc9033e8ddbf"
    sha256 cellar: :any, arm64_linux:       "e211189290538c161c510dfc67459e9ff3c18005cfdc7d31307275e32b93a21d"
    sha256 cellar: :any, x86_64_linux:      "6f7c7f8dc8eead3790d4306d844d5926f199764896921ef4aee87beac4e7fd3c"
  end

  depends_on "openssl@4"

  deny_network_access!

  def install
    # "test" was added to std::atomic_flag in C++20
    # See https://github.com/rgaufman/live555/issues/45
    ENV.append "CXXFLAGS", "-std=c++20"

    # Avoid linkage to system OpenSSL
    libs = [
      formula_opt_lib("openssl@4")/shared_library("libcrypto"),
      formula_opt_lib("openssl@4")/shared_library("libssl"),
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
