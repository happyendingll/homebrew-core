class EvilHelix < Formula
  desc "Soft fork of the helix editor"
  homepage "https://evil-helix.github.io"
  license "MPL-2.0"
  head "https://github.com/usagi-flow/evil-helix.git", branch: "main"

  stable do
    url "https://github.com/usagi-flow/evil-helix/archive/refs/tags/release-20250915.tar.gz"
    sha256 "1a5dc826890eede336b2f2cabbb1bb19b3e25ebbc0c42ac09eb7d9348bbf27cc"

    # Backport the gotmpl grammar switch, its previous repository was deleted
    patch do
      url "https://github.com/usagi-flow/evil-helix/commit/7ea891969ae2592403ce1ee2c84fa119133c5cea.patch?full_index=1"
      sha256 "d9c4eb16ca38063c9bd4d40ec77dc3ee334d16ba6af14f38273c3a319594219e"
      type :backport
      resolves "https://github.com/helix-editor/helix/pull/14746"
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "e8fcbec4747256f1503ec19b231d776e1c4a0711709b0b8ad79ce1d72a8e44d3"
  end

  depends_on "rust" => :build

  conflicts_with "helix", because: "both install `hx` binaries"
  conflicts_with "hex", because: "both install `hx` binaries"

  def install
    ENV["HELIX_DEFAULT_RUNTIME"] = libexec/"runtime"
    system "cargo", "install", "-vv", *std_cargo_args(path: "helix-term")
    rm_r "runtime/grammars/sources/"
    libexec.install "runtime"

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  test do
    file = "https://raw.githubusercontent.com/usagi-flow/evil-helix/refs/tags/release-#{version}/Cargo.toml"
    version = shell_output("curl #{file}")&.gsub!(/.0$/i, "")
    assert_match version.to_s, shell_output("#{bin}/hx --version")
    assert_match "✓", shell_output("#{bin}/hx --health")
  end
end
