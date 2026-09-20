class Darkice < Formula
  desc "Live audio streamer"
  homepage "http://www.darkice.org/"
  url "https://github.com/rafael2k/darkice/archive/refs/tags/v1.6.tar.gz"
  sha256 "52807d887d60646776110b63543d3845ebe9ed52d3eea44bed7c4bdd95b6575e"
  license "GPL-3.0-or-later"
  revision 2

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "1cd67b42359ecfab719490d13e62f2e6f749f77d158baad63f3dfb510c23a3e4"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build

  depends_on "faac"
  depends_on "jack"
  depends_on "lame"
  depends_on "libogg"
  depends_on "libsamplerate"
  depends_on "libvorbis"
  depends_on "two-lame"

  on_linux do
    depends_on "alsa-lib"
  end

  # Support faac 2.0 API
  patch :p2 do
    url "https://github.com/rafael2k/darkice/commit/af8c0ad5904bf7bc97ec2d4dfb8f883397009c9d.patch?full_index=1"
    sha256 "c599afb642d374332d63220c80914d3e369400cda3b60068183460d1120fec35"
    directory "darkice/trunk"
    type :unofficial
    resolves "https://github.com/rafael2k/darkice/pull/216"
  end

  def install
    # TODO: Remove when source is back to the release tarball
    cd "darkice/trunk" do
      system "autoreconf", "--install", "--force", "--verbose"

      system "./configure", "--sysconfdir=#{etc}",
                            "--with-lame-prefix=#{formula_opt_prefix("lame")}",
                            "--with-faac-prefix=#{formula_opt_prefix("faac")}",
                            "--without-fdkaac",
                            "--with-twolame",
                            "--with-jack",
                            "--with-vorbis",
                            "--with-samplerate",
                            "--without-opus",
                            *std_configure_args
      system "make", "install"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/darkice -h", 1)
  end
end
