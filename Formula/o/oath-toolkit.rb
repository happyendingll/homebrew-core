class OathToolkit < Formula
  desc "Tools for one-time password authentication systems"
  homepage "https://oath-toolkit.codeberg.page/"
  url "https://download.savannah.nongnu.org/releases/oath-toolkit/oath-toolkit-2.6.15.tar.gz"
  mirror "https://download-mirror.savannah.gnu.org/releases/oath-toolkit/oath-toolkit-2.6.15.tar.gz"
  sha256 "8ad24aa9ff13c0edf3efc2573d90e85cf8b5ce7e82c08042574c1591f9d91eaa"
  license all_of: ["GPL-3.0-or-later", "LGPL-2.1-or-later"]

  livecheck do
    url "https://download.savannah.gnu.org/releases/oath-toolkit/"
    regex(/href=.*?oath-toolkit[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "efb6a991d25864418c8725d6c1bfc0c250bd24eadb7329f3cf6f21f085ede8f9"
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
