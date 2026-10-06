class Simutrans < Formula
  desc "Transport simulator"
  homepage "https://www.simutrans.com/"
  url "svn://servers.simutrans.org/simutrans/trunk/", revision: "12334"
  version "125.0.1"
  license "Artistic-1.0"
  head "https://github.com/simutrans/simutrans.git", branch: "master"

  livecheck do
    url "https://sourceforge.net/projects/simutrans/files/simutrans/"
    regex(%r{href=.*?/files/simutrans/(\d+(?:[.-]\d+)+)/}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match[0].tr("-", ".") }
    end
  end

  no_autobump! because: :incompatible_version_format

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "2cb7e3123e255a10af1a32df9c78dfac02f01521d4becd096133186a2c040773"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "fluid-synth"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "miniupnpc"
  depends_on "sdl2-compat"
  depends_on "zstd"

  uses_from_macos "unzip" => :build
  uses_from_macos "bzip2"
  uses_from_macos "curl"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "pak64" do
    url "https://downloads.sourceforge.net/project/simutrans/pak64/125-0/simupak64-125-0.zip"
    sha256 "850108b76505ca306822b88c22a1829c7102a6c9d7390c057f533ba70d9ecdad"
  end

  resource "soundfont" do
    url "https://src.fedoraproject.org/repo/pkgs/PersonalCopy-Lite-soundfont/PCLite.sf2/629732b7552c12a8fae5b046d306273a/PCLite.sf2"
    sha256 "ba3304ec0980e07f5a9de2cfad3e45763630cbc15c7e958c32ce06aa9aefd375"
  end

  # Translations are downloaded during `build` phase
  allow_network_access! :build

  def install
    # These translations are dynamically generated.
    system "./tools/get_lang_files.sh"

    system "cmake", "-B", "build", "-S", ".", "-DSIMUTRANS_USE_REVISION=#{stable.specs[:revision]}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--build", "build", "--target", "makeobj"
    system "cmake", "--build", "build", "--target", "nettool"

    simutrans_path = OS.mac? ? "simutrans/simutrans.app/Contents/MacOS" : "simutrans"
    libexec.install "build/#{simutrans_path}/simutrans" => "simutrans"
    libexec.install Dir["simutrans/*"]
    bin.write_exec_script libexec/"simutrans"
    bin.install "build/src/makeobj/makeobj"
    bin.install "build/src/nettool/nettool"

    libexec.install resource("pak64")
    (libexec/"music").install resource("soundfont")
  end

  test do
    system bin/"simutrans", "--help"
  end
end
