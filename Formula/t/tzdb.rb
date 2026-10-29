class Tzdb < Formula
  desc "Time Zone Database"
  homepage "https://www.iana.org/time-zones"
  url "https://data.iana.org/time-zones/releases/tzdb-2026f.tar.lz"
  sha256 "357829e3a16a78224d23f1ae2327704c1da1fd35f6769a7aac0682755fb9027a"
  license all_of: ["BSD-3-Clause", :public_domain]

  livecheck do
    url "https://ftp.iana.org/tz/releases/"
    regex(/href=.*?tzdb[._-]v?(\d+(?:\.\d+)*[a-z]?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 sequoia: "c116f627724cc5e166283d3ac63ce1be5ba476c258775e58532a6de93a408c70"
  end

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    make_args = %W[
      CFLAGS=#{ENV.cflags}
      USRDIR=#{prefix}
      TZDEFAULT=#{etc/"localtime"}
    ]
    make_args << "LDLIBS=-lintl" if OS.mac?

    system "make", *make_args, "install"
  end

  post_install_steps do
    run "zic", args: ["-l", "Factory", "-p", "-", "-t", "{{etc}}/localtime"], base: :sbin
  end

  test do
    assert_match "UTC", shell_output("#{bin}/zdump UTC")
  end
end
