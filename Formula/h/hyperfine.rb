class Hyperfine < Formula
  desc "Command-line benchmarking tool"
  homepage "https://github.com/sharkdp/hyperfine"
  url "https://github.com/sharkdp/hyperfine/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "f4b71df3c78e4cf752ca6fb6ebc4b025f7ea6a5ca5c48fea75f8a1fdb4c7d721"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/sharkdp/hyperfine.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "5e6f76872d06044920df2cdb151faf6f845997f6e3ea2575e62eb78cf794ac3d"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["SHELL_COMPLETIONS_DIR"] = buildpath

    system "cargo", "install", *std_cargo_args

    bash_completion.install "hyperfine.bash" => "hyperfine"
    fish_completion.install "hyperfine.fish"
    zsh_completion.install "_hyperfine"
    man1.install "doc/hyperfine.1"
  end

  test do
    output = shell_output("#{bin}/hyperfine 'sleep 0.3'")
    assert_match "Benchmark 1: sleep", output
  end
end
