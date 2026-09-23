class Oxvg < Formula
  desc "Fastest SVG toolchain for optimisation, minification, linting, and actions"
  homepage "https://github.com/noahbald/oxvg"
  url "https://github.com/noahbald/oxvg/archive/refs/tags/v0.0.8.tar.gz"
  sha256 "48cd09db206039b530f9ac8e214a68699a82773c5ed508c63baf080bd4a4e754"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "2f4ff2d0de17ff6b6c63e1fee2c6de14e1010e23682968da48bac3ce42d5abb2"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/oxvg")
  end

  test do
    input = '<svg><path d="m0 0l0 1"/></svg>'
    assert_equal '<svg><path d="M0 0v1"/></svg>', pipe_output("#{bin}/oxvg optimise", input, 0)
  end
end
