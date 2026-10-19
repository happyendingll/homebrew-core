class Snobol4 < Formula
  desc "String oriented and symbolic programming language"
  homepage "https://www.regressive.org/snobol4/"
  url "https://ftp.regressive.org/snobol/snobol4-2.3.5.tar.gz"
  sha256 "07154314d458be00936b1dd8592a32be25d5b8fc27e6bf1b73ada904886e86e2"
  license "BSD-2-Clause"

  livecheck do
    url "https://ftp.regressive.org/snobol/"
    regex(/href=.*?snobol4[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "0a117a3f364b5e75ee3db86a97db6051be59310c303d7aa917c70fec52d25230"
  end

  depends_on "openssl@4"

  uses_from_macos "m4" => :build
  uses_from_macos "libffi"
  uses_from_macos "sqlite"

  on_linux do
    depends_on "readline"
    depends_on "zlib-ng-compat"
  end

  conflicts_with "sdb", because: "both install `sdb` binaries"

  def install
    ENV.append_to_cflags "-I#{MacOS.sdk_path}/usr/include/ffi" if OS.mac?
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    ENV.deparallelize
    # avoid running benchmark:
    system "make", "install_notiming"
  end

  test do
    # Verify modules build, test DBM.
    # NOTE! 1960's language! -include, comment, and labels (fail, end)
    # must all be in first column
    testfile = testpath/"test.sno"
    dbmfile = testpath/"test.dbm"
    (testpath/"test.sno").write <<~EOS
      -include 'digest.sno'
      -include 'dirs.sno'
      -include 'ezio.sno'
      -include 'ffi.sno'
      -include 'fork.sno'
      -include 'ndbm.sno'
      -include 'logic.sno'
      -include 'random.sno'
      -include 'sprintf.sno'
      -include 'sqlite3.sno'
      -include 'stat.sno'
      -include 'zlib.sno'
      * DBM test
              t = 'dbm'
              k = '🍺'
              v = '🙂'
              fn = '#{dbmfile}'
              h1 = dbm_open(fn, 'cw')         :f(fail)
              dbm_store(h1, k, v)             :f(fail)
              dbm_close(h1)                   :f(fail)
              h2 = dbm_open(fn, 'r')          :f(fail)
              v2 = dbm_fetch(h2, k)           :f(fail)
              ident(v, v2)                    :f(fail)
      * more tests here? (set t to test name before each test)
	      output = 'OK'
              :(end)
      fail    output = t ' test failed at ' &LASTLINE
              &code = 1
      end
    EOS
    assert_match "OK", shell_output("#{bin}/snobol4 #{testfile}")
  end
end
