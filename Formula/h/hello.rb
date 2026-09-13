class Hello < Formula
  desc "Program providing model for GNU coding standards and practices"
  homepage "https://www.gnu.org/software/hello/"
  url "https://ftpmirror.gnu.org/hello/hello-2.12.3.tar.gz"
  sha256 "0d5f60154382fee10b114a1c34e785d8b1f492073ae2d3a6f7b147687b366aa0"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "5719123485941ec4ec84e753a5885359ccc069e72aabf6b8a76823340ba2391b"
  end

  deny_network_access!

  def install
    ENV.append "LDFLAGS", "-liconv" if OS.mac?

    system "./configure", "--disable-dependency-tracking", *std_configure_args
    system "make", "install"
  end

  test do
    assert_equal "brew", shell_output("#{bin}/hello --greeting=brew").chomp
  end
end
