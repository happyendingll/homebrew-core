class Srtp < Formula
  desc "Implementation of the Secure Real-time Transport Protocol"
  homepage "https://github.com/cisco/libsrtp"
  url "https://github.com/cisco/libsrtp/archive/refs/tags/v2.8.1.tar.gz"
  sha256 "ef5569220749529d778013aae1178391d972570a2b4f7288dda22effa875b07c"
  license "BSD-3-Clause"
  revision 1
  compatibility_version 1
  head "https://github.com/cisco/libsrtp.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "7c7dee827b062942fba932587711798b1370a4d277c9ce66a9bf903c02323da0"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  deny_network_access!

  def install
    system "./configure", "--enable-openssl", *std_configure_args
    system "make", "test"
    system "make", "shared_library"
    system "make", "install" # Can't go in parallel of building the dylib
    libexec.install "test/rtpw"
  end

  test do
    system libexec/"rtpw", "-l"
  end
end
