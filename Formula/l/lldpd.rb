class Lldpd < Formula
  desc "Implementation of IEEE 802.1ab (LLDP)"
  homepage "https://lldpd.github.io/"
  url "https://media.luffy.cx/files/lldpd/lldpd-1.0.22.tar.gz"
  sha256 "9587940ed2314a86774c5499f3dfb13a8eb86232a62d243a83a1f09886848e03"
  license "ISC"

  livecheck do
    url :homepage
    regex(/href=.*?lldpd[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "293ce338c906d5489f9d951d25bd4cc5722d2be04562454dae6f6c8dfb024474"
  end

  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "readline"

  uses_from_macos "libxml2"

  def install
    args = %W[
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-privsep-chroot=/var/empty
      --with-privsep-group=nogroup
      --with-privsep-user=nobody
      --with-readline
      --with-xml
      --without-launchddaemonsdir
      --without-snmp
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"

    (var/"run").mkpath
  end

  service do
    run opt_sbin/"lldpd"
    keep_alive true
    require_root true
  end
end
