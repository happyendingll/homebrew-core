class Fq < Formula
  desc "Brokered message queue optimized for performance"
  homepage "https://github.com/circonus-labs/fq"
  url "https://github.com/circonus-labs/fq/archive/refs/tags/v0.13.12.tar.gz"
  sha256 "4329fa7678437c2d22f021ec8a5bed2b7a7eeb608bbfe4c8749f8520011b12d3"
  license "MIT"
  head "https://github.com/circonus-labs/fq.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "a1bd99150326dea59beefdf7e0a1f6046c48b6aa649413a8d2a8157ef78fcf6f"
  end

  depends_on "concurrencykit"
  depends_on "jlog"

  uses_from_macos "sqlite"

  on_linux do
    depends_on "bind" => :test # for `dig`
    depends_on "openssl@4"
    depends_on "util-linux"
  end

  def install
    ENV.append_to_cflags "-DNO_BCD=1"
    inreplace "Makefile", "-lbcd", ""
    inreplace "Makefile", "/usr/lib/dtrace", "#{lib}/dtrace"
    system "make", "PREFIX=#{prefix}"
    args = ["PREFIX=#{prefix}"]
    args << "ENABLE_DTRACE=0" unless OS.mac?
    system "make", "install", *args
    bin.install "fqc", "fq_sndr", "fq_rcvr"
  end

  test do
    ipv4 = shell_output("dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '\"'").strip
    port = free_port
    pid = spawn sbin/"fqd", "-p", port.to_s, "-n", ipv4, "-D", "-c", testpath/"test.sqlite"
    begin
      output = shell_output("curl --silent --retry 5 --retry-connrefused 127.0.0.1:#{port}")
      assert_match "Circonus Fq Operational Dashboard", output
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
