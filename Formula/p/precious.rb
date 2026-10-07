class Precious < Formula
  desc "One code quality tool to rule them all"
  homepage "https://github.com/houseabsolute/precious"
  url "https://github.com/houseabsolute/precious/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "2de1f5ed8d9013065577d51e6ec3762e6cb1db7aff20e0495f312416728e2e07"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/houseabsolute/precious.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "38092eeb4b596620f4dd5905f3272d3ba0994e212e336fbf2ad70d69f6d06467"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/precious --version")

    (testpath/"test.rs").write "fn main() {}\n"
    system bin/"precious", "config", "init", "--auto"
    assert_path_exists testpath/"precious.toml"
    assert_match "rustfmt", (testpath/"precious.toml").read
  end
end
