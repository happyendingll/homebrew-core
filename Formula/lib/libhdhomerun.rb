class Libhdhomerun < Formula
  desc "C library for controlling SiliconDust HDHomeRun TV tuners"
  homepage "https://github.com/Silicondust/libhdhomerun"
  url "https://download.silicondust.com/hdhomerun/libhdhomerun_20261107.tgz"
  sha256 "a273f2267b32e8931a7b733d37a28367fa65ee5ce875036d0acd5b2948edc07d"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://download.silicondust.com/hdhomerun/libhdhomerun.tgz"
    regex(/libhdhomerun[._-]v?(\d+(?:\.\d+)*)\.t/i)
    strategy :header_match
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "34d4f526ada3dd28902eebb1409598b5f63965addecc61480a4ba55bf479ff9c"
  end

  def install
    suffix = if OS.mac?
      Hardware::CPU.arm? ? "_arm64" : "_x64"
    else
      ""
    end

    targets = ["hdhomerun_config#{suffix}", shared_library("libhdhomerun#{suffix}")]

    system "make", *targets
    bin.install "hdhomerun_config#{suffix}" => "hdhomerun_config"
    lib.install shared_library("libhdhomerun#{suffix}") => shared_library("libhdhomerun")
    include.install Dir["hdhomerun*.h"]
  end

  test do
    # Devices may be found or not found, with differing return codes
    discover = pipe_output("#{bin}/hdhomerun_config discover")
    assert_match(/no devices found|hdhomerun device|found at/, discover)
  end
end
