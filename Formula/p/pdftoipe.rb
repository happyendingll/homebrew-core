class Pdftoipe < Formula
  desc "Reads arbitrary PDF files and generates an XML file readable by Ipe"
  homepage "https://github.com/otfried/ipe-tools"
  url "https://github.com/otfried/ipe-tools/archive/refs/tags/v7.2.29.2.tar.gz"
  sha256 "c8de0dc7eb8fa959c96539fb19ebfb8e16f459e9b4ef9259aeb30b76072cd083"
  license "GPL-2.0-or-later"
  revision 6

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "7bb662de0554ef4e0dcb5f00b1626f550a9e09f80d08edce677d2a644a1c1f72"
  end

  depends_on "pkgconf" => :build
  depends_on "poppler"

  # Workaround for poppler 26.06.
  patch do
    url "https://github.com/otfried/ipe-tools/commit/3875da3ae31515dad4f2aa7ac5f59f2c2f70c32c.patch?full_index=1"
    sha256 "15369effacfa0df2559049a1dcc01f20036b0a158bb3059c6ce333287549de7a"
    type :backport
    resolves "https://github.com/otfried/ipe-tools/pull/82"
  end

  def install
    cd "pdftoipe" do
      system "make"
      bin.install "pdftoipe"
      man1.install "pdftoipe.1"
    end
  end

  test do
    cp test_fixtures("test.pdf"), testpath
    system bin/"pdftoipe", "test.pdf"
    assert_match "<ipestyle>", File.read("test.ipe")
  end
end
