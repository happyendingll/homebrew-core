class Siege < Formula
  desc "HTTP regression testing and benchmarking utility"
  homepage "https://www.joedog.org/siege"
  url "https://download.joedog.org/siege/siege-4.2.2.tar.gz"
  sha256 "c0d5bfac11086aeb3828888a71bf276ed54c9fa0f0af2ead981d2b2fa242141b"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://download.joedog.org/siege/?C=M&O=D"
    regex(/href=.*?siege[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "cded3d2c31b0d885d341d12feb6f6005ffea83f8eaba8946be77b332ee094f0f"
  end

  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    # workaround for newer clang
    # notified upstream on the site on 2024-09-10
    ENV.append_to_cflags "-Wno-int-conversion" if DevelopmentTools.clang_build_version >= 1403

    # To avoid unnecessary warning due to hardcoded path, create the folder first
    (prefix/"etc").mkdir

    zlib = OS.mac? ? "#{MacOS.sdk_path}/usr" : formula_opt_prefix("zlib-ng-compat")
    args = %W[
      --localstatedir=#{var}
      --with-ssl=#{formula_opt_prefix("openssl@4")}
      --with-zlib=#{zlib}
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  def caveats
    <<~EOS
      macOS has only 16K ports available that won't be released until socket
      TIME_WAIT is passed. The default timeout for TIME_WAIT is 15 seconds.
      Consider reducing in case of available port bottleneck.

      You can check whether this is a problem with netstat:

          # sysctl net.inet.tcp.msl
          net.inet.tcp.msl: 15000

          # sudo sysctl -w net.inet.tcp.msl=1000
          net.inet.tcp.msl: 15000 -> 1000

      Run siege.config to create the ~/.siegerc config file.
    EOS
  end

  test do
    system bin/"siege", "--concurrent=1", "--reps=1", "https://www.google.com/"
  end
end
