class MinLang < Formula
  desc "Small but practical concatenative programming language and shell"
  homepage "https://min-lang.org"
  url "https://git.sr.ht/~h3rald/min/archive/v0.48.1.tar.gz"
  sha256 "baec4d176ff138fcf39784ad97a6a9125454a8d3ccb4db3e6ea59aa2d6716a45"
  license "MIT"
  revision 2

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "e374d31ac5bef662bf4090edcdac725e8233f76390bcd4a4440857f88ce9ed07"
  end

  depends_on "nim"
  depends_on "openssl@4"

  on_linux do
    disable! date: "2027-11-13", because: "needs EOL `pcre`"

    depends_on "pcre"
  end

  deny_network_access!

  def fetch
    system "nimble", "install", "--depsOnly"
  end

  def install
    # Remove bundled libraries
    rm_r(["minpkg/vendor/openssl", "minpkg/vendor/pcre"])
    inreplace_files = ["minpkg/lib/min_crypto.nim", "minpkg/lib/min_http.nim", "minpkg/lib/min_global.nim"]
    inreplace inreplace_files, /passL: "-B?static /, 'passL: "'

    system "nimble", "build"
    bin.install "min"
  end

  test do
    testfile = testpath/"test.min"
    testfile.write <<~EOS
      sys.pwd sys.ls (fs.type "file" ==) filter '> sort
      puts!
    EOS
    assert_match testfile.to_s, shell_output("#{bin}/min test.min")
  end
end
