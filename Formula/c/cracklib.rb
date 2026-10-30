class Cracklib < Formula
  desc "LibCrack password checking library"
  homepage "https://github.com/cracklib/cracklib"
  url "https://github.com/cracklib/cracklib/releases/download/v2.10.4/cracklib-2.10.4.tar.bz2"
  sha256 "4f2d151a2930ab2644def5f9e0e4dad7446ccbd3f2dd41960e91398d93c3129e"
  license "LGPL-2.1-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "ef22ba082b5df498f610d8c0328a77911491b674f2975d8e52d00a6b36ce1006"
  end

  head do
    url "https://github.com/cracklib/cracklib.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "cracklib-words" do
    url "https://github.com/cracklib/cracklib/releases/download/v2.10.4/cracklib-words-2.10.4.bz2"
    sha256 "ec25ac4a474588c58d901715512d8902b276542b27b8dd197e9c2ad373739ec4"

    livecheck do
      formula :parent
    end
  end

  deny_network_access!

  def install
    buildpath.install (buildpath/"src").children if build.head?
    system "autoreconf", "--force", "--install", "--verbose" if build.head?

    system "./configure", "--disable-silent-rules",
                          "--sbindir=#{bin}",
                          "--without-python",
                          "--with-default-dict=#{var}/cracklib/cracklib-words",
                          *std_configure_args
    system "make", "install"

    share.install resource("cracklib-words")
  end

  post_install_steps do
    mkdir_p "cracklib", base: :var
    copy "cracklib-words-*", "cracklib/cracklib-words", source_base: :share, target_base: :var, source_glob: true
    run "cracklib-packer", base: :bin, stdin_path: "{{var}}/cracklib/cracklib-words"
  end

  test do
    assert_match "password: it is based on a dictionary word", pipe_output(bin/"cracklib-check", "password", 0)
  end
end
