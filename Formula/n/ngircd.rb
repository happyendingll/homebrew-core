class Ngircd < Formula
  desc "Lightweight Internet Relay Chat server"
  homepage "https://ngircd.barton.de/"
  url "https://arthur.barton.de/pub/ngircd/ngircd-28.tar.xz"
  mirror "https://ngircd.sourceforge.io/pub/ngircd/ngircd-28.tar.xz"
  sha256 "b48ba320a931d445ae335c47f88a9406a20f5c71c623bee5f7755d0522d435ee"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://ngircd.barton.de/download.php"
    regex(/href=.*?ngircd[._-]v?(\d+(?:\.\d+)*)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "e65c27bc33b0d0982694d4eb45bee8c9ed0dc164a6234787931f82683e7e5210"
  end

  depends_on "libident"
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules",
                          "--sysconfdir=#{etc}",
                          "--enable-ipv6",
                          "--with-ident",
                          "--with-openssl",
                          *std_configure_args
    system "make", "install"

    if OS.mac?
      prefix.install "contrib/de.barton.ngircd.plist"
      (prefix/"de.barton.ngircd.plist").chmod 0644

      inreplace prefix/"de.barton.ngircd.plist" do |s|
        s.gsub! "/opt/ngircd/sbin", sbin
        s.gsub! "/Library/Logs/ngIRCd.log", var/"Logs/ngIRCd.log"
      end
    end
  end

  test do
    # Exits non-zero, so test version and match Author's name supplied.
    assert_match "Alexander", pipe_output("#{sbin}/ngircd -V 2>&1")
  end
end
