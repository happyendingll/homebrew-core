class UBootTools < Formula
  desc "Universal boot loader"
  homepage "https://u-boot-project.org/"
  url "https://git.u-boot-project.org/u-boot/u-boot/-/releases/v2026.10/downloads/u-boot-2026.10.tar.bz2"
  sha256 "3f856da3cbbc93af51ff95fde18588a348b4a26723b01d9841e999d988481015"
  license all_of: ["GPL-2.0-only", "GPL-2.0-or-later", "BSD-3-Clause"]
  head "https://git.u-boot-project.org/u-boot/u-boot.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "7fbba37cb0912943c3861b3a534c523137239fd5feeb707a110f9be6cc66ff37"
  end

  depends_on "coreutils" => :build # Makefile needs $(gdate)
  depends_on "openssl@3" # https://lists.u-boot-project.org/pipermail/u-boot/2026-April/616722.html

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_macos do
    depends_on "make" => :build
  end

  def install
    # Disable mkeficapsule
    inreplace "configs/tools-only_defconfig", "CONFIG_TOOLS_MKEFICAPSULE=y", "CONFIG_TOOLS_MKEFICAPSULE=n"

    system "gmake", "tools-only_defconfig"
    system "gmake", "tools-only", "NO_SDL=1"
    bin.install "tools/mkimage", "tools/dumpimage", "tools/mkenvimage"
    man1.install "doc/mkimage.1", "doc/dumpimage.1"
  end

  test do
    system bin/"mkimage", "-V"
    system bin/"dumpimage", "-V"
    system bin/"mkenvimage", "-V"
  end
end
