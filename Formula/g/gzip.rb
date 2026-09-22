class Gzip < Formula
  desc "Popular GNU data compression program"
  homepage "https://www.gnu.org/software/gzip/"
  url "https://ftpmirror.gnu.org/gzip/gzip-1.15.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gzip/gzip-1.15.tar.gz"
  sha256 "545886cf57fa88a65e967fbf705903d7fcb2567c82c7342493e82e8d7b1a210b"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "b553f807cd1a2c3e4ea8f3e5ba378efcf2859dd4130dbb9ce7906201e1751ed8"
  end

  # Fix compile error on aarch64 Linux
  # gzip.h:120:21: error: expected ')' before '+' token
  patch do
    url "https://raw.githubusercontent.com/OpenMandrivaAssociation/gzip/5a3c8e5316bac3ac837f7aa8dc7e3a4b0ba74321/gzip-1.15-aarch64-head-macro.patch"
    sha256 "82ef5b24041eeb86511ce67cb4e60edf8fbfcce01f7a1ab28fd1e024a3050df0"
    type :unofficial
    resolves "https://lists.gnu.org/archive/html/bug-gzip/2026-09/msg00031.html"
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"foo").write "test"
    system bin/"gzip", "foo"
    system bin/"gzip", "-t", "foo.gz"
    assert_equal "test", shell_output("#{bin}/gunzip -c foo")
  end
end
