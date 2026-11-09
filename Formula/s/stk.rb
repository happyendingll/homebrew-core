class Stk < Formula
  desc "Sound Synthesis Toolkit"
  homepage "https://ccrma.stanford.edu/software/stk/"
  url "https://ccrma.stanford.edu/software/stk/release/stk-5.0.1.tar.gz"
  sha256 "afc35faea3bb8baacacb8d9db3fa745e4f7d8dd46f36aac5436ca377d565a184"
  license "MIT"
  compatibility_version 1

  livecheck do
    url "https://ccrma.stanford.edu/software/stk/download.html"
    regex(/href=.*?stk[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e09e9bdad683f2a7f5a51aba0bbe84f9f0a2b01f5f64020f5832620c38efc8b4"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  on_linux do
    depends_on "alsa-lib"
  end

  deny_network_access!

  def install
    system "./configure", *std_configure_args.reject { |s| s["--disable-dependency-tracking"] }
    system "make"

    lib.install "src/libstk.a"
    bin.install "bin/treesed"

    (include/"stk").install Dir["include/*"]
    doc.install Dir["doc/*"]
    pkgshare.install "src", "projects", "rawwaves"
  end

  def caveats
    <<~EOS
      The header files have been put in a standard search path, it is possible to use an include statement in programs as follows:

        #include "stk/FileLoop.h"
        #include "stk/FileWvOut.h"

      src/ projects/ and rawwaves/ have all been copied to #{opt_pkgshare}
    EOS
  end

  test do
    assert_equal "xx No input files", shell_output("#{bin}/treesed", 1).chomp
  end
end
