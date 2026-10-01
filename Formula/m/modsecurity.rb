class Modsecurity < Formula
  desc "Libmodsecurity is one component of the ModSecurity v3 project"
  homepage "https://github.com/owasp-modsecurity/ModSecurity"
  url "https://github.com/owasp-modsecurity/ModSecurity/releases/download/v3.0.17/modsecurity-v3.0.17.tar.gz"
  sha256 "f283b33d5c21130fd3a15c84a93a1abe12bd1949edaf44288b12af571b671a50"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "bdbdcff18dc28274d5adbe1a6c54abb104344aff611243b3ce70e45a4c9e8701"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libmaxminddb"
  depends_on "lua"
  depends_on "pcre2"
  depends_on "yajl"

  uses_from_macos "curl", since: :monterey
  uses_from_macos "libxml2"

  def install
    system "autoreconf", "--force", "--install", "--verbose"

    libxml2 = OS.mac? ? "#{MacOS.sdk_path}/usr" : formula_opt_prefix("libxml2")

    args = [
      "--disable-debug-logs",
      "--disable-doxygen-html",
      "--disable-examples",
      "--disable-silent-rules",
      "--with-libxml=#{libxml2}",
      "--with-lua=#{formula_opt_prefix("lua")}",
      "--with-pcre2=#{formula_opt_prefix("pcre2")}",
      "--with-yajl=#{formula_opt_prefix("yajl")}",
      "--without-geoip",
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/modsec-rules-check \"SecAuditEngine RelevantOnly\"")
    assert_match("Test ok", output)
  end
end
