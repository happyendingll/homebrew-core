class I2pd < Formula
  desc "Full-featured C++ implementation of I2P client"
  homepage "https://i2pd.website/"
  url "https://github.com/PurpleI2P/i2pd/archive/refs/tags/3.0.0.1.tar.gz"
  sha256 "e82d4cdcce71180a42f89a753012db9aa303a792afc3e442802761f099ee39e4"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "7dab6d665c2df05e700ae1411c5389b9d1ed0f78b07746c76c91691a4f8f1cfd"
  end

  depends_on "boost"
  depends_on "miniupnpc"
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = %W[
      DEBUG=no
      HOMEBREW=1
      USE_UPNP=yes
      PREFIX=#{prefix}
      BREWROOT=#{HOMEBREW_PREFIX}
      SSLROOT=#{formula_opt_prefix("openssl@4")}
    ]
    args << "USE_AESNI=no" if Hardware::CPU.arm?

    system "make", "install", *args

    # preinstall to prevent overwriting changed by user configs
    rm_r(prefix/"etc")
    pkgetc.install doc/"i2pd.conf", doc/"subscriptions.txt", doc/"tunnels.conf"

    (var/"lib/i2pd").mkpath
    (var/"log/i2pd").mkpath
  end

  post_install_steps do
    # Create symlinks to certificates and configs
    symlink "{{pkgshare}}/certificates",    "{{var}}/lib/i2pd/certificates",      overwrite: true
    symlink "{{pkgetc}}/i2pd.conf",         "{{var}}/lib/i2pd/i2pd.conf",         overwrite: true
    symlink "{{pkgetc}}/subscriptions.txt", "{{var}}/lib/i2pd/subscriptions.txt", overwrite: true
    symlink "{{pkgetc}}/tunnels.conf",      "{{var}}/lib/i2pd/tunnels.conf",      overwrite: true
  end

  service do
    run [opt_bin/"i2pd", "--datadir=#{var}/lib/i2pd", "--conf=#{etc}/i2pd/i2pd.conf",
         "--tunconf=#{etc}/i2pd/tunnels.conf", "--log=file", "--logfile=#{var}/log/i2pd/i2pd.log",
         "--pidfile=#{var}/run/i2pd.pid"]
  end

  test do
    pidfile = testpath/"i2pd.pid"
    system bin/"i2pd", "--datadir=#{testpath}", "--pidfile=#{pidfile}", "--daemon"
    sleep 5
    assert_path_exists testpath/"router.keys", "Failed to start i2pd"
    pid = pidfile.read.chomp.to_i
    begin
      Process.kill("TERM", pid)
    rescue Errno::ESRCH
      # Process already terminated
    end
  end
end
