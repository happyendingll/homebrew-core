class Freesasa < Formula
  desc "Solvent Accessible Surface Area calculations"
  homepage "https://freesasa.github.io/"
  url "https://github.com/mittinatten/freesasa/archive/refs/tags/2.1.4.tar.gz"
  sha256 "1bc79b06985c868f76ccc5ff8fea6a1687c7d4d4b21e5c3636b52106b653807c"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "36017edb726a2121448cd2cd52be9c2b869b2a30e9adee3826aea413866a9fa7"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "json-c"

  uses_from_macos "libxml2"

  deny_network_access!

  def install
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
    pkgshare.install "tests/data"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/freesasa --version")

    output = shell_output("#{bin}/freesasa #{pkgshare}/data/3bkr.pdb")
    assert_match "RESULTS", output
  end
end
