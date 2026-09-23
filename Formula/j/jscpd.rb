class Jscpd < Formula
  desc "Copy/paste detector for programming source code"
  homepage "https://jscpd.dev/"
  url "https://github.com/kucherenko/jscpd/archive/refs/tags/v5.3.2.tar.gz"
  sha256 "8025dce319a520a8e48906fbbdb8377f297d1fffd9542d27141edf10741d90b3"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "4a250c48ec6e8fb4589194f417f2d64e52d00937e8839185683ea7ff976ec591"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "rust/Cargo.toml"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "rust/crates/cpd")
  end

  test do
    test_file = testpath/"test.js"
    test_file2 = testpath/"test2.js"
    test_file.write <<~JAVASCRIPT
      console.log("Hello, world!");
    JAVASCRIPT
    test_file2.write <<~JAVASCRIPT
      console.log("Hello, brewtest!");
    JAVASCRIPT

    output = shell_output("#{bin}/jscpd --min-lines 1 #{testpath}/*.js 2>&1")
    assert_match "Found 0 clones", output

    assert_match version.to_s, shell_output("#{bin}/jscpd --version")
  end
end
