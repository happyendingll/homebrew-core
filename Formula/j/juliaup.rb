class Juliaup < Formula
  desc "Julia installer and version multiplexer"
  homepage "https://github.com/JuliaLang/juliaup"
  url "https://github.com/JuliaLang/juliaup/archive/refs/tags/v1.24.0.tar.gz"
  sha256 "e33d53a71cd3c54537af21ffa935f60046a2b6e84708b533d7c5876f5ce5ffe5"
  license "MIT"
  head "https://github.com/JuliaLang/juliaup.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "60c40341bc7f3eca980cfdcf1b0ba1d004c631cb74301a826a8b70bc42fecebf"
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
