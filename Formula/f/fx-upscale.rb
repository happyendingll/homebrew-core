class FxUpscale < Formula
  desc "Metal-powered video upscaling"
  homepage "https://github.com/finnvoor/fx-upscale"
  url "https://github.com/finnvoor/fx-upscale/archive/refs/tags/1.3.2.tar.gz"
  sha256 "4dc10cbbd23acbede656215259ac3644e9472915840243409b34c6bc471ff11d"
  license "CC0-1.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e505e79d908e944173ad5f61f2249445d123b285c5a400175fd5c1c97890eef4"
  end

  depends_on macos: :ventura

  uses_from_macos "swift" => :build # swift 5.9+

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/fx-upscale"
  end

  test do
    cp test_fixtures("test.mp4"), testpath
    # Upscaling needs VideoToolbox services that the test sandbox denies,
    # so only check that the video track is read before the size validation
    output = shell_output("#{bin}/fx-upscale --width 20000 #{testpath}/test.mp4 2>&1", 64)
    assert_match "Maximum supported width/height: 16384", output
  end
end
