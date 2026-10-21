class Zabbix < Formula
  desc "Availability and monitoring solution"
  homepage "https://www.zabbix.com/"
  url "https://cdn.zabbix.com/zabbix/sources/stable/7.4/zabbix-7.4.16.tar.gz"
  sha256 "0e2c391dc184acce8e34250e7326a51e19c8bcee31e67b8497f5526247ecd261"
  license "AGPL-3.0-only"
  head "https://github.com/zabbix/zabbix.git", branch: "master"

  livecheck do
    url "https://www.zabbix.com/download_sources"
    regex(/href=.*?zabbix[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "d53647ed4a0984fb9e46dd5e56ecb7d95179384276eddcadb7519d732ffdc47d"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"
  depends_on "pcre2"

  deny_network_access!

  def install
    args = %W[
      --enable-agent
      --enable-ipv6
      --with-libpcre2
      --sysconfdir=#{pkgetc}
      --with-openssl=#{formula_opt_prefix("openssl@4")}
    ]

    if OS.mac?
      sdk = MacOS::CLT.installed? ? "" : MacOS.sdk_path
      args << "--with-iconv=#{sdk}/usr"
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    system sbin/"zabbix_agentd", "--print"
  end
end
