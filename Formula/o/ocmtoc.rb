class Ocmtoc < Formula
  desc "Mach-O to PE/COFF binary converter"
  homepage "https://github.com/acidanthera/ocmtoc"
  url "https://github.com/acidanthera/ocmtoc/archive/refs/tags/1.0.4.tar.gz"
  sha256 "dbc33ca5d5ae436b2845e36fc13ba878261480788db86fc6daab89dc5588e51a"
  license "APSL-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e0b4dfd6d45ccb5f8948a04933aabcd91f29ffa8194f8970f4fe7b713967f6e3"
  end

  depends_on xcode: :build
  depends_on :macos

  conflicts_with "mtoc", because: "both install `mtoc` binaries"

  def install
    xcodebuild "-arch", Hardware::CPU.arch,
               "-project", "cctools.xcodeproj",
               "-scheme", "mtoc",
               "-configuration", "Release",
               "CONFIGURATION_BUILD_DIR=build/Release",
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    bin.install "build/Release/mtoc"
    man1.install "man/mtoc.1"
  end

  test do
    (testpath/"test.c").write <<~C
      __attribute__((naked)) int start() {}
    C

    args = %W[
      -nostdlib
      -Wl,-preload
      -Wl,-e,_start
      -seg1addr 0x1000
      -o #{testpath}/test
      #{testpath}/test.c
    ]
    system ENV.cc, *args
    system bin/"mtoc", testpath/"test", testpath/"test.pe"
  end
end
