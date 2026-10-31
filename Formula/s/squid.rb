class Squid < Formula
  desc "Advanced proxy caching server for HTTP, HTTPS, FTP, and Gopher"
  homepage "https://www.squid-cache.org/"
  url "https://github.com/squid-cache/squid/releases/download/SQUID_7_8/squid-7.8.tar.bz2"
  sha256 "0fcebf10aec14449abff30eb4cf7230f27d080601516d891f90a7e705de9f68e"
  license "GPL-2.0-or-later"

  # Upstream sometimes creates releases that use a stable tag (e.g., `v1.2.3`)
  # but are labeled as "pre-release" on GitHub, so it's necessary to use the
  # `GithubLatest` strategy.
  livecheck do
    url :stable
    regex(/^SQUID[._-]v?(\d+(?:[._]\d+)+)$/i)
    strategy :github_latest do |json, regex|
      json["tag_name"]&.[](regex, 1)&.tr("_", ".")
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "8b38673c52b97c393f7d2da99d45b7f3d8984f6723e20b4a5c1e7f96f2bea478"
  end

  head do
    url "https://github.com/squid-cache/squid.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@3" # TODO: OpenSSL 4 PR - https://github.com/squid-cache/squid/pull/2501

  uses_from_macos "libxcrypt"

  def install
    # https://stackoverflow.com/questions/20910109/building-squid-cache-on-os-x-mavericks
    ENV.append "LDFLAGS", "-lresolv"

    # For --disable-eui, see:
    # https://www.squid-cache.org/mail-archive/squid-users/201304/0040.html
    args = %W[
      --localstatedir=#{var}
      --sysconfdir=#{etc}
      --enable-ssl
      --enable-ssl-crtd
      --disable-eui
      --with-included-ltdl
      --with-gnutls=no
      --with-nettle=no
      --with-openssl
      --enable-delay-pools
      --enable-disk-io=yes
      --enable-removal-policies=yes
      --enable-storeio=yes
    ]

    args << "--enable-pf-transparent" if OS.mac?

    system "./bootstrap.sh" if build.head?
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  service do
    run [opt_sbin/"squid", "-N", "-d 1"]
    keep_alive true
    working_dir var
    log_path var/"log/squid.log"
    error_log_path var/"log/squid.log"
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/squid -v")

    pid = spawn sbin/"squid"

    begin
      sleep 2
      system sbin/"squid", "-k", "check"
    ensure
      system sbin/"squid", "-k", "interrupt"
      Process.wait(pid)
    end
  end
end
