class Lldpd < Formula
  desc "Implementation of IEEE 802.1ab (LLDP)"
  homepage "https://lldpd.github.io/"
  url "https://media.bernat.ch/files/lldpd/lldpd-1.0.23.tar.gz"
  sha256 "b65fc380e2063a3fb15555f413f192a63006f6fd0c81fd524e3a43851700c48b"
  license "ISC"

  livecheck do
    url :homepage
    regex(/href=.*?lldpd[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "1070c7b7bbdc82611d09607be3c5bdcdf68d8863b9cbf56d92e951e7732e1c1d"
  end

  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "readline"

  uses_from_macos "libxml2"

  deny_network_access!

  def install
    rm_r("libevent")

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

  test do
    output = shell_output("#{sbin}/lldpcli -u #{testpath}/lldpd.socket show neighbors 2>&1", 1)
    assert_match "unable to connect to socket #{testpath}/lldpd.socket", output
  end
end
