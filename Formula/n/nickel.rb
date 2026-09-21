class Nickel < Formula
  desc "Better configuration for less"
  homepage "https://nickel-lang.org/"
  url "https://github.com/nickel-lang/nickel/archive/refs/tags/1.18.0.tar.gz"
  sha256 "ddcac13684c1fc174a45e0e179ff4ef9433eb08f08bbf4b386dc722cf64ab2d5"
  license "MIT"
  head "https://github.com/nickel-lang/nickel.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?((?!9\.9\.9)\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "680d11267e2af237b6f39efe38d29a1e0a01de3cf3424533227e1bebc02b915e"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["NICKEL_NIX_BUILD_REV"] = tap.user.to_s

    system "cargo", "install", *std_cargo_args(path: "cli")

    generate_completions_from_executable(bin/"nickel", "gen-completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nickel --version")

    (testpath/"program.ncl").write <<~NICKEL
      let s = "world" in "Hello, " ++ s
    NICKEL

    output = shell_output("#{bin}/nickel eval program.ncl")
    assert_match "Hello, world", output
  end
end
