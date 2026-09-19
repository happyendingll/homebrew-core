class Hatari < Formula
  desc "Atari ST/STE/TT/Falcon emulator"
  homepage "https://www.hatari-emu.org/"
  license "GPL-2.0-or-later"

  stable do
    url "https://framagit.org/hatari/releases/-/raw/main/v2.6.1/hatari-2.6.1.tar.bz2"
    sha256 "b7dc09ebffc1b77da6837d37b116bc5a9b2fd46affff1021124101e3f6e76bc5"
    depends_on "sdl2-compat"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "5d89260e087bf1ccef94ed51a9d9fcd3bbb18c527adfd3106f6a1b1eb55a62a3"
  end

  head do
    url "https://framagit.org/hatari/hatari.git", branch: "main"
    depends_on "sdl3"
  end

  depends_on "cmake" => :build
  depends_on "libpng"

  on_linux do
    depends_on "libx11"
    depends_on "readline"
    depends_on "zlib-ng-compat"
  end

  # Download EmuTOS ROM image
  resource "emutos" do
    url "https://downloads.sourceforge.net/project/emutos/emutos/1.4/emutos-1024k-1.4.zip"
    sha256 "dc9fbef6455a24ee8955cccd565588c718ba675fd54bc5a749003ac4bbd7f7e1"

    livecheck do
      url "https://sourceforge.net/projects/emutos/rss?path=/emutos"
      regex(%r{/emutos[._-]1024k[._-](\d+(?:\.\d+)+)\.z}i)
    end
  end

  def install
    if OS.mac?
      args = %W[
        -DCMAKE_DISABLE_FIND_PACKAGE_X11=ON
        -DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch}
        -DENABLE_OSX_BUNDLE=OFF
      ]
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    resource("emutos").stage do
      pkgshare.install "etos1024k.img" => "tos.img"
    end
  end

  test do
    assert_match "Hatari v#{version} -", shell_output("#{bin}/hatari -v", 1)
  end
end
