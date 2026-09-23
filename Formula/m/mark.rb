class Mark < Formula
  desc "Sync your markdown files with Confluence pages"
  homepage "https://samizdat.dev"
  url "https://github.com/kovetskiy/mark/archive/refs/tags/v16.20.0.tar.gz"
  sha256 "3f760566829b6bdf598c60a01556cbdb8cce6b021f4fb5ef5102df224af27c32"
  license "Apache-2.0"
  head "https://github.com/kovetskiy/mark.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "82e0324521db463d597613015c14fa7a93dae24b1a576247676cf70ac5a4a9a8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "82e0324521db463d597613015c14fa7a93dae24b1a576247676cf70ac5a4a9a8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "82e0324521db463d597613015c14fa7a93dae24b1a576247676cf70ac5a4a9a8"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ab2e3a138c5a1f7b5b9c3d8a7f5635a9a16ff11e9a8955de8e6a1810af58c23f"
    sha256 cellar: :any,                 x86_64_linux:      "fa6b8f683ad3f5d3d6958edf21928720a46bdb592f260158e51913c1ec3cd629"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/mark"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mark --version")

    (testpath/"test.md").write <<~MARKDOWN
      # Hello Homebrew
    MARKDOWN

    touch testpath/"mark.toml"
    output = shell_output("#{bin}/mark --config mark.toml sync 2>&1", 1)
    assert_match "confluence base URL should be specified", output
  end
end
