class Juliaup < Formula
  desc "Julia installer and version multiplexer"
  homepage "https://github.com/JuliaLang/juliaup"
  url "https://github.com/JuliaLang/juliaup/archive/refs/tags/v1.23.0.tar.gz"
  sha256 "d18228e0fff256863d0aabb71d72c2664601647dbd582c29b51b437f6bfb9bac"
  license "MIT"
  head "https://github.com/JuliaLang/juliaup.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "44435220d2ea613346e2b7364da2d613acabfcf2b363a57e85bd0492858304d5"
  end

  depends_on "rust" => :build

  conflicts_with "julia", because: "both install `julia` binaries"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", "--bin", "juliaup", *std_cargo_args
    system "cargo", "install", "--bin", "julialauncher", *std_cargo_args(features: "binjulialauncher")
    system "cargo", "install", *std_cargo_args(path: "juliaupgui")

    bin.install_symlink "julialauncher" => "julia"

    generate_completions_from_executable(bin/"juliaup", "completions")
  end

  test do
    expected = "Default  Channel  Version  Update"
    assert_equal expected, shell_output("#{bin}/juliaup status").lines.first.strip
    assert_path_exists bin/"juliaupgui"
  end
end
