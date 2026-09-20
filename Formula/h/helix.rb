class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  url "https://github.com/helix-editor/helix/releases/download/25.07.1/helix-25.07.1-source.tar.xz"
  sha256 "2d0cf264ac77f8c25386a636e2b3a09a23dec555568cc9a5b2927f84322f544e"
  license "MPL-2.0"
  head "https://github.com/helix-editor/helix.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "f26a2d2c291639ae51ad9e6fd4874493684e7f25766beee04df93aa517dbaa42"
  end

  depends_on "rust" => :build

  conflicts_with "evil-helix", because: "both install `hx` binaries"
  conflicts_with "hex", because: "both install `hx` binaries"

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"

    # HEAD builds need to fetch grammar sources bundled in release tarballs.
    system "cargo", "run", "--locked", "--package", "helix-loader", "--bin", "hx-loader" if build.head?
  end

  def install
    if build.head?
      # Build the fetched grammars explicitly without trying to fetch them again.
      ENV["HELIX_DISABLE_AUTO_GRAMMAR_BUILD"] = "1"
      ENV["CARGO_MANIFEST_DIR"] = buildpath/"helix-term"
    end
    system "cargo", "install", "-vv", *std_cargo_args(path: "helix-term")
    system bin/"hx", "--grammar", "build", "--strict" if build.head?
    rm_r "runtime/grammars/sources/"
    libexec.install "runtime"
    bin.env_script_all_files libexec/"bin", HELIX_RUNTIME: "${HELIX_RUNTIME:-#{libexec}/runtime}"

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  test do
    assert_match "post-modern text editor", shell_output("#{bin}/hx --help")
    assert_match "✓", shell_output("#{bin}/hx --health")
  end
end
