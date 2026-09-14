class Picotool < Formula
  desc "Tool for interacting with RP2040/RP2350 devices and binaries"
  homepage "https://github.com/raspberrypi/picotool"
  license "BSD-3-Clause"

  stable do
    url "https://github.com/raspberrypi/picotool/archive/refs/tags/2.3.1.tar.gz"
    sha256 "07946d294ab5c474b610660c53c5d94216e4ab13555de075ed521f98afc4f44c"

    resource "pico-sdk" do
      # Use git checkout to allow fetching mbedtls submodule
      url "https://github.com/raspberrypi/pico-sdk.git",
          tag:      "2.3.1",
          revision: "079c6f39023649b154152db30f1d781e884879bc"

      livecheck do
        formula :parent
      end
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "7bc59a2862c073a8ff98ccd1da5a00f85936c1340b72fbfff16484f4f3a8cd37"
  end

  head do
    url "https://github.com/raspberrypi/picotool.git", branch: "master"

    resource "pico-sdk" do
      url "https://github.com/raspberrypi/pico-sdk.git", branch: "master"
    end
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libusb"

  def install
    odie "pico-sdk resource needs to be updated" if build.stable? && version != resource("pico-sdk").version

    resource("pico-sdk").stage buildpath/"pico-sdk"

    args = %W[-DPICO_SDK_PATH=#{buildpath}/pico-sdk]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # from https://github.com/raspberrypi/pico-examples?tab=readme-ov-file#first-examples
    resource "homebrew-blink_universal" do
      url "https://datasheets.raspberrypi.com/soft/blink_picow.uf2"
      sha256 "d1e68082a74d3ffac56bc45b1e2df05810704f2cf7b32d2b0e2519b7dffcfee6"
    end

    resource("homebrew-blink_universal").stage do
      result = <<~EOS
        File blink_universal.uf2 family ID 'rp2040':

        Program Information
         name:          blink_universal
         web site:      https://github.com/raspberrypi/pico-examples/tree/HEAD/universal/blink_universal
         binary start:  0x10000000
         binary end:    0x100403e4
      EOS
      assert_equal result, shell_output("#{bin}/picotool info blink_universal.uf2")
    end
  end
end
