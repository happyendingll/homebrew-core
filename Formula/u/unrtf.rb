class Unrtf < Formula
  desc "RTF to other formats converter"
  homepage "https://www.gnu.org/software/unrtf/"
  url "https://ftpmirror.gnu.org/unrtf/unrtf-0.21.12.tar.gz"
  mirror "https://ftp.gnu.org/gnu/unrtf/unrtf-0.21.12.tar.gz"
  sha256 "59ad6062fb1d7ab4d89dd0316a3cee19f5e719525a5387b6da6b69b3178e2098"
  license "GPL-3.0-or-later"
  head "https://hg.savannah.gnu.org/hgweb/unrtf/", using: :hg

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "40be92ce72f18b15781832d2204fc238a8b69b6da7f2b04e0c7eec7ecbf6fd3d"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  # Fix macOS build errors, MacPorts PR ref, https://github.com/macports/macports-ports/pull/34986
  patch :p0 do
    on_macos do
      url "https://raw.githubusercontent.com/macports/macports-ports/658984b1c0c8032c32a27969853d7e958e9ae6e9/textproc/unrtf/files/patch-src_execdir.c.diff"
      sha256 "66a8f3509bdf69899c8a8a2b7dfae94a1916b3e8778e69443ab89548a4d3ab84"
      type :unofficial
      resolves "https://github.com/macports/macports-ports/pull/34986"
    end
  end

  def install
    # C23 treats the upstream's unprototyped function pointers as zero-argument functions
    ENV["ac_cv_prog_cc_c23"] = "no"

    system "./bootstrap"
    args = %W[--prefix=#{prefix}]
    args << "LIBS=-liconv" if OS.mac?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.rtf").write <<~'RTF'
      {\rtf1\ansi
      {\b hello} world
      }
    RTF
    expected = <<~HTML
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
      <html>
      <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8">
      <!-- Translation from RTF performed by UnRTF, version #{version} -->
      </head>
      <body><b>hello</b> world</body>
      </html>
    HTML
    assert_equal expected, shell_output("#{bin}/unrtf --html test.rtf")
  end
end
