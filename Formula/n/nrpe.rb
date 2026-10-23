class Nrpe < Formula
  desc "Nagios remote plugin executor"
  homepage "https://www.nagios.org/"
  url "https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.2.0/nrpe-4.2.0.tar.gz"
  sha256 "0d1eac6845d360b200b037f2b8c0199f1acbe3bea36ad72236ad619e5447e555"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "263888ac5e44d28f57b68a2cdcb7ddff3d1c4e9e63ca9196a88ca6baf251abaf"
  end

  depends_on "nagios-plugins"
  depends_on "openssl@3"

  allow_network_access! :test

  def install
    user  = `id -un`.chomp
    group = `id -gn`.chomp

    if OS.linux?
      ENV["tmpfilesd"] = etc/"tmpfiles.d"
      (etc/"tmpfiles.d").mkpath
    end

    system "./configure", "--prefix=#{prefix}",
                          "--libexecdir=#{HOMEBREW_PREFIX}/sbin",
                          "--with-piddir=#{var}/run",
                          "--sysconfdir=#{etc}",
                          "--with-nrpe-user=#{user}",
                          "--with-nrpe-group=#{group}",
                          "--with-nagios-user=#{user}",
                          "--with-nagios-group=#{group}",
                          "--with-ssl=#{formula_opt_prefix("openssl@3")}",
                          # Set both or it still looks for /usr/lib
                          "--with-ssl-lib=#{formula_opt_lib("openssl@3")}",
                          "--enable-ssl",
                          "--enable-command-args"

    inreplace "src/Makefile" do |s|
      s.gsub! "$(LIBEXECDIR)", "$(SBINDIR)"
      s.gsub! "$(DESTDIR)#{HOMEBREW_PREFIX}/sbin", "$(SBINDIR)"
    end

    system "make", "all"
    system "make", "install", "install-config"

    (var/"run").mkpath
  end

  service do
    run [opt_bin/"nrpe", "-c", etc/"nrpe.cfg", "-d"]
  end

  def port_open?(ip_address, port, seconds = 1)
    Timeout.timeout(seconds) do
      TCPSocket.new(ip_address, port).close
    end
    true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
    false
  end

  test do
    port = free_port
    cp etc/"nrpe.cfg", testpath
    inreplace "nrpe.cfg", /^server_port=5666$/, "server_port=#{port}"

    pid = spawn bin/"nrpe", "-n", "-c", testpath/"nrpe.cfg", "-d"
    sleep 2

    begin
      assert port_open?("localhost", port), "nrpe did not start"
      pid_nrpe = shell_output("pgrep nrpe").to_i
    ensure
      Process.kill("SIGINT", pid_nrpe) if pid_nrpe
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
