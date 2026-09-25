class Swtpm < Formula
  desc "Software TPM Emulator based on libtpms"
  homepage "https://github.com/stefanberger/swtpm"
  url "https://github.com/stefanberger/swtpm/archive/refs/tags/v0.10.2.tar.gz"
  sha256 "f61cf6f1e9bbcb4cefb30b70cafaf1c4df54c6961e65cfa63830e8ad0e220134"
  license "BSD-3-Clause"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "8822aed2f068d56a7f16b8e8714c53276ffbc6fcaed95f301d52293dd00c2b61"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gawk" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "socat" => :build
  depends_on "glib"
  depends_on "gmp"
  depends_on "json-glib"
  depends_on "libtasn1"
  depends_on "libtpms"
  depends_on "openssl@4"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "libseccomp"
    depends_on "net-tools"
  end

  # Backport changes to drop GnuTLS
  patch do
    url "https://github.com/stefanberger/swtpm/commit/86c6046cbe0e913e884683d20acec3949a4a1220.patch?full_index=1"
    sha256 "8f0c469d178004128c97645f4bb849355473ad0181d6063c6dc5ba1565b716a0"
    type :backport
    resolves "https://github.com/stefanberger/swtpm/pull/1094"
  end

  allow_network_access! :test

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("openssl@4")/"pkgconfig"
    system "./autogen.sh", "--disable-tests", "--with-openssl", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    port = free_port
    pid = spawn bin/"swtpm", "socket", "--ctrl", "type=tcp,port=#{port}"
    sleep 10
    system bin/"swtpm_ioctl", "--tcp", "127.0.0.1:#{port}", "-s"
  ensure
    Process.wait pid
  end
end
