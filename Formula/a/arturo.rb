class Arturo < Formula
  desc "Simple, modern and portable programming language for efficient scripting"
  homepage "https://arturo-lang.io/"
  url "https://github.com/arturo-lang/arturo/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "408646496895753608ad9dc6ddfbfa25921c03c4c7356f2832a9a63f4a7dc351"
  license "MIT"
  revision 2

  # TODO: remove if undeprecated
  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "97f5932731637ef4ce00968f78666eac6d0b39ebc0b69255e1b0b948ccd0c2f3"
  end

  depends_on "nim" => :build
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "openssl@4"

  on_linux do
    disable! date: "2027-11-13", because: "needs EOL `pcre`"

    depends_on "pkgconf" => :build
    depends_on "glib"
    depends_on "gtk+3"
    depends_on "libxcb"
    depends_on "pcre" # https://github.com/arturo-lang/arturo/issues/2027
    depends_on "webkitgtk"
  end

  # Fix build with Nim 2.2.12
  patch do
    url "https://github.com/arturo-lang/arturo/commit/3e11ad40074b15103785b4a40532107b049315bc.patch?full_index=1"
    sha256 "a0720b777c37950587f71e5aa13bdb65ca8d228166d616a391d3d860580c156b"
    type :backport
  end

  deny_network_access!

  def install
    # Remove bundled libraries
    rm_r("src/deps")

    # FIXME: Unbundle OpenSSL. Should find a way to do this upstream
    inreplace "src/library/Net.nim",
              /\{\.passL: "[^"]*(-lcrypto|libcrypto\.a)[^"]*"\.\}/,
              "{.passL: \"-Wl,-rpath,#{formula_opt_lib("openssl@4")} -lssl -lcrypto\".}"

    inreplace "src/vm/values/custom/vregex.nim",
              /\{\.passL: "[^"]*(-lpcre|libpcre\.a)[^"]*"\.\}/,
              "{.passL: \"-lpcre\"}"

    # Adjust installation path to homebrew one
    inreplace "build.nims", 'targetDir = getHomeDir()/".arturo"', "targetDir=\"#{prefix}\""

    system "./build.nims", "--install", "--log"
  end

  test do
    (testpath/"hello.art").write <<~EOS
      print "hello"
    EOS
    assert_equal "hello", shell_output("#{bin}/arturo #{testpath}/hello.art").chomp
  end
end
