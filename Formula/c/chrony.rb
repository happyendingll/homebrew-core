class Chrony < Formula
  desc "Versatile implementation of the Network Time Protocol (NTP)"
  homepage "https://chrony-project.org"
  url "https://chrony-project.org/releases/chrony-4.9.tar.gz"
  sha256 "4924c6f530105bcd5b9e9e33c48a2ae1bfd889222c8480bc41601110efc864d0"
  license "GPL-2.0-only"

  livecheck do
    url "https://chrony-project.org/download.html"
    regex(/href=.*?chrony[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "fdbbd55ddb833f23de9e879fe96e4b479adf7e9d11fdb1c28b070a5e5df64da3"
  end

  depends_on "pkgconf" => :build
  depends_on "gnutls"
  depends_on "nettle"

  uses_from_macos "libedit"

  allow_network_access! :test

  def install
    system "./configure", "--localstatedir=#{var}", *std_configure_args
    system "make", "install"
  end

  test do
    port = free_port
    (testpath/"server.conf").write <<~EOS
      port #{port}
      bindaddress 127.0.0.1
      allow 127.0.0.1
      local stratum 10
      cmdport 0
      bindcmdaddress /
      pidfile #{testpath}/server.pid
    EOS
    (testpath/"client.conf").write "server 127.0.0.1 port #{port} iburst\n"

    server = spawn sbin/"chronyd", "-U", "-x", "-d", "-f", testpath/"server.conf", [:out, :err] => File::NULL
    begin
      output = shell_output("#{sbin}/chronyd -Q -f #{testpath}/client.conf 2>&1")
      assert_match(/System clock wrong by -?\d+\.\d+ seconds \(ignored\)/, output)
    ensure
      Process.kill "TERM", server
      Process.wait server
    end
  end
end
