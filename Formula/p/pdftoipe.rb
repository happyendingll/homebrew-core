class Pdftoipe < Formula
  desc "Reads arbitrary PDF files and generates an XML file readable by Ipe"
  homepage "https://github.com/otfried/ipe-tools"
  url "https://github.com/otfried/ipe-tools/archive/refs/tags/v7.3.1.2.tar.gz"
  sha256 "edb8f098c32f0ae626ac20ebdd0f2114fc1d1cc4d730a7abb648cfe9c131e40d"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "261caf3792de92c8c1f7902b1e3f75db09e6da1671a29b94e76f8f9ad4085a9a"
  end

  depends_on "pkgconf" => :build
  depends_on "poppler"

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
