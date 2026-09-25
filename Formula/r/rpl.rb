class Rpl < Formula
  desc "Text replacement utility"
  homepage "https://github.com/rrthomas/rpl"
  url "https://github.com/rrthomas/rpl/releases/download/v2.1.2/rpl-2.1.2.tar.gz"
  sha256 "7994ef8663a51779ab1fb3a730cf2ae6cda81cc905b6db9ae0e858f63cb8b3e1"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "64425e453526fd0e6a850cd5c38432ecbba3357c6fcab48d76164b950d1201ab"
  end

  depends_on "help2man" => :build
  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "pcre2"
  depends_on "uchardet"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test").write "I like water."

    system bin/"rpl", "-v", "water", "beer", "test"
    assert_equal "I like beer.", (testpath/"test").read
  end
end
