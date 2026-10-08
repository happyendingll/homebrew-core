class OathToolkit < Formula
  desc "Tools for one-time password authentication systems"
  homepage "https://oath-toolkit.codeberg.page/"
  url "https://download.savannah.nongnu.org/releases/oath-toolkit/oath-toolkit-2.6.14.tar.gz"
  mirror "https://download-mirror.savannah.gnu.org/releases/oath-toolkit/oath-toolkit-2.6.14.tar.gz"
  sha256 "8b1da365759f1249be57a82aec6e107f7b57dc77d813f96dc0aaf81624f28971"
  license all_of: ["GPL-3.0-or-later", "LGPL-2.1-or-later"]
  revision 4

  livecheck do
    url "https://download.savannah.gnu.org/releases/oath-toolkit/"
    regex(/href=.*?oath-toolkit[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "0233cac8249dd8deaf20a9138324abd939b6f0ef18db6f18d47094ca842d34c4"
  end

  head do
    url "https://codeberg.org/oath-toolkit/oath-toolkit.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gtk-doc"  => :build
    depends_on "libtool"  => :build
  end

  depends_on "pkgconf" => :build

  depends_on "libxml2"
  depends_on "libxmlsec1"

  def install
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac? # avoid openssl linkage

    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    assert_equal "328482", shell_output("#{bin}/oathtool 00").chomp
  end
end
