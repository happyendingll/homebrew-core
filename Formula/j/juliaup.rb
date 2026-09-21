class Juliaup < Formula
  desc "Julia installer and version multiplexer"
  homepage "https://github.com/JuliaLang/juliaup"
  url "https://github.com/JuliaLang/juliaup/archive/refs/tags/v1.22.7.tar.gz"
  sha256 "220d0d58db0a46d8676cc4972149789899c1e68386a5260b08e135622921d7bf"
  license "MIT"
  head "https://github.com/JuliaLang/juliaup.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "d0dba3ae12a2ae4f61a564437e66efe6c3de8ef95ce8934348faecabbff5ce80"
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
