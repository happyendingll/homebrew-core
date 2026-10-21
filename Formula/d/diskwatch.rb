class Diskwatch < Formula
  desc "Cross-platform disk diagnostics TUI"
  homepage "https://www.netwatchlabs.com/labs/diskwatch"
  url "https://github.com/matthart1983/diskwatch/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "0c85e1f3d7edb600fff80778813f9c507db4c663f61b2fc017c1ba1ad3d2caf8"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "a23c16c7c08b772e5e2ee8a3748e7772e6370453d0651fbb31892c24b5fc6667"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "Devices", shell_output("#{bin}/diskwatch --diag")
  end
end
