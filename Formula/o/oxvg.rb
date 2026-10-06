class Oxvg < Formula
  desc "Fastest SVG toolchain for optimisation, minification, linting, and actions"
  homepage "https://github.com/noahbald/oxvg"
  url "https://github.com/noahbald/oxvg/archive/refs/tags/v0.0.9.tar.gz"
  sha256 "9f6fbc2385784bcca8a3411fbbd7deb690799d0866bc5f5d7cd88756b7746af6"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "47d984e08513181e91e1531bac5950c99f8b17eb33046c9df716fd30551c0f47"
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
