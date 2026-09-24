class Socat < Formula
  desc "SOcket CAT: netcat on steroids"
  homepage "http://www.dest-unreach.org/socat/"
  url "https://distfiles.alpinelinux.org/distfiles/edge/socat-1.8.1.3.tar.gz"
  mirror "http://www.dest-unreach.org/socat/download/socat-1.8.1.3.tar.gz"
  sha256 "06602ffd591e98c75b3dc1d66f0f19136cc666b0b2d95caad987d6ab2cb28097"
  license "GPL-2.0-only"
  compatibility_version 1

  livecheck do
    url "http://www.dest-unreach.org/socat/download/"
    regex(/href=.*?socat[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "5d92eeee78ba631a2b6958c8e78d2c455f83caba90d35d44d4abf5bc44228c4e"
  end

  depends_on "openssl@4"

  # Apply Fedora patch to support OpenSSL 4.0. Same change is used by Debian
  # (10-Use-OpenSSL-ASN1_STRING-accessor-functions-instead-o.patch)
  patch do
    url "https://src.fedoraproject.org/rpms/socat/raw/c0b6576097257ad24cd6f72948bada8bca9a588c/f/socat-1.8.1.0-openssl4.patch"
    sha256 "66258fb1b1f65236ad8da8cbfb689485356423e7f280dc8e524dc012c11a5687"
    type :unofficial
  end

  # Test connects to a remote host
  allow_network_access! :test

  def install
    # NOTE: readline must be disabled as the license is incompatible with GPL-2.0-only,
    # https://www.gnu.org/licenses/gpl-faq.html#AllCompatibility
    system "./configure", "--disable-readline", *std_configure_args
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/socat - tcp:www.google.com:80", "GET / HTTP/1.0\r\n\r\n")
    assert_match "HTTP/1.0", output.lines.first
  end
end
