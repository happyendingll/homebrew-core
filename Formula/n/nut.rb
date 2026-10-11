class Nut < Formula
  desc "Network UPS Tools: Support for various power devices"
  homepage "https://networkupstools.org/"
  url "https://github.com/networkupstools/nut/releases/download/v2.8.5/nut-2.8.5.tar.gz"
  sha256 "18bf32e59eb764b13da3c4fa70384926d7fa584cb31d2fe7f137a570633eeec1"
  license "GPL-2.0-or-later"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "bfb8518e12dcbcbc4e3c227899636eb28f6834f56f774c1edfa7440fa542b2ca"
  end

  head do
    url "https://github.com/networkupstools/nut.git", branch: "master"
    depends_on "asciidoc" => :build
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libusb"
  depends_on "openssl@4"

  on_linux do
    depends_on "glib"
    depends_on "systemd"
  end

  conflicts_with "rhino", because: "both install `rhino` binaries"

  def install
    if build.head?
      ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"
      system "./autogen.sh"
    end

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --localstatedir=#{var}
      --sysconfdir=#{etc}/nut
      --with-statepath=#{var}/state/ups
      --with-pidpath=#{var}/run
      --with-systemdtmpfilesdir=#{pkgshare}
      --with-openssl
      --with-serial
      --with-usb
      --without-avahi
      --without-cgi
      --without-dev
      --without-doc
      --without-ipmi
      --without-libltdl
      --without-neon
      --without-nss
      --without-nut_monitor
      --without-powerman
      --without-pynut
      --without-snmp
      --without-wrap
    ]
    if OS.mac?
      args << "--with-macosx_ups"
    else
      args += %W[
        --with-udev-dir=#{lib}/udev
        --with-systemdsystemunitdir=#{lib}/systemd/system
        --with-systemdsystempresetdir=#{lib}/systemd/system-preset
        --with-systemdshutdowndir=#{lib}/systemd/system-shutdown
        --with-systemdsysusersdir=#{lib}/sysusers.d
      ]
    end

    system "./configure", *args
    system "make", "install"

    (var/"state/ups").mkpath
    (var/"run").mkpath
  end

  service do
    run [opt_sbin/"upsmon", "-D"]
  end

  test do
    system bin/"dummy-ups", "-L"
  end
end
