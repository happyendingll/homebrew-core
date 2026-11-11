class Hivex < Formula
  desc "Library and tools for extracting the contents of Windows Registry hive files"
  homepage "https://libguestfs.org"
  url "https://download.libguestfs.org/hivex/hivex-1.3.25.tar.gz"
  sha256 "10fe3b31c0c6ee8bd82749d3161321bfc2e2f3b986a77cdce1ef8987d1296605"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-only"]

  livecheck do
    url "https://download.libguestfs.org/hivex/"
    regex(/href=.*?hivex[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "bfc7a63410c61c9a70d2bcf7a785872bc282d502eab514a8798f0db47466d7bb"
  end

  depends_on "pkgconf" => :build
  depends_on "readline"

  uses_from_macos "pod2man" => :build
  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    # Work around `-Wl,-M` usage. This was fixed in parent project (libguestfs) but not yet in hivex
    # https://github.com/libguestfs/libguestfs/commit/e17d794d11090b2f221bfd93acb6a8da046a2540
    inreplace "configure", '"-Wl,-M -Wl,"', '"-Wl,-map -Wl,"' if DevelopmentTools.clang_build_version >= 1500

    args = %w[
      --disable-ocaml
      --disable-perl
      --disable-python
      --disable-ruby
      --disable-silent-rules
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
    (pkgshare/"test").install "images/large"
  end

  test do
    assert_equal "305419896", shell_output("#{bin}/hivexget #{pkgshare}/test/large 'A\\A giant' B").chomp
  end
end
