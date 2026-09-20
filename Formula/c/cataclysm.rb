class Cataclysm < Formula
  desc "Fork/variant of Cataclysm Roguelike"
  homepage "https://github.com/CleverRaven/Cataclysm-DDA"
  url "https://github.com/CleverRaven/Cataclysm-DDA/archive/refs/tags/0.I-1.tar.gz"
  version "0.I-1"
  sha256 "27e35a0a5181f88f0929bef180ca0465d00e606e569911cb02d97b59b8b5768a"
  license "CC-BY-SA-3.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.(?:\d+|\w))+(?:[_-]\d+)?)/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "09e00130f52b5f9f794b4492e4f620ebe20873c83e7841ef4631f610c2b61ffa"
  end

  head do
    url "https://github.com/CleverRaven/Cataclysm-DDA.git", branch: "master"

    on_macos do
      depends_on "freetype"
    end
  end

  depends_on "gettext" => :build # for msgfmt
  depends_on "pkgconf" => :build
  depends_on "freetype"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "sdl2-compat"
  depends_on "sdl2_image"
  depends_on "sdl2_mixer"
  depends_on "sdl2_ttf"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    args = %W[
      NATIVE=#{os}
      RELEASE=1
      USE_HOME_DIR=1
      TILES=1
      SOUND=1
      RUNTESTS=0
      TESTS=0
      ASTYLE=0
      LINTJSON=0
    ]

    args << "OSX_MIN=#{MacOS.version}" if OS.mac?
    args << "CLANG=1" if ENV.compiler == :clang

    system "make", *args

    # no make install, so we have to do it ourselves
    libexec.install "cataclysm-tiles", "data", "gfx"

    inreplace "cataclysm-launcher" do |s|
      s.change_make_var! "DIR", libexec
    end
    bin.install "cataclysm-launcher" => "cataclysm"
  end

  test do
    # make user config directory
    user_config_dir = if OS.mac?
      testpath/"Library/Application Support/Cataclysm"
    else
      testpath/".cataclysm-dda"
    end
    user_config_dir.mkpath

    # "Error while initializing the interface: SDL_Init failed: No available video device"
    ENV["SDL_VIDEODRIVER"] = "dummy"

    # run cataclysm for 50 seconds
    tries = 0
    pid = spawn bin/"cataclysm"
    begin
      sleep 5
      assert_path_exists user_config_dir/"config", "User config directory should exist"
    rescue Minitest::Assertion
      retry if (tries += 1) < 10
      raise
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
