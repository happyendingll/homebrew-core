class Fio < Formula
  desc "I/O benchmark and stress test"
  homepage "https://github.com/axboe/fio"
  url "https://github.com/axboe/fio/archive/refs/tags/fio-3.43.tar.gz"
  sha256 "efa49b3f36eda9adf29294f27a87d7e457747d676cd0f73996d6365357832cfe"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^fio[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "dde20e0b54030caa722c8513d9df934ec2818bc226b8fcd8a53f22f6457c546e"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  conflicts_with "fiona", because: "both install `fio` binaries"

  def install
    # fio's configure script passes `-march` flags as part of detecting CRC
    # support on ARM. By default brew's logic removes such flags, resulting
    # in the prope falsely succeeding (probes compile when they shouldn't)
    # and `ARCH_HAVE_CRC_CRYPTO` being enabled when it shouldn't, giving a
    # compile time failure later in the build.
    # Solve by enabling `runtime_cpu_detection` which configures brew not
    # to strip those flags, so the configure probe fails correctly when it
    # should.
    ENV.runtime_cpu_detection
    # fio's' configure script enables `-march=native` by default. Disable
    # this to ensure binaries are portable. Ordinarily brew's logic would
    # remove `-march` flags by default - but we disabled that above.
    system "./configure", "--disable-native"
    # fio's CFLAGS passes vital stuff around, and crushing it will break the build
    system "make", "prefix=#{prefix}",
                   "mandir=#{man}",
                   "sharedir=#{share}",
                   "CC=#{ENV.cc}",
                   "V=true", # get normal verbose output from fio's makefile
                   "install"
  end

  test do
    system bin/"fio", "--parse-only"
  end
end
