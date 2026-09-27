class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.21.10.tar.gz"
  sha256 "7d9174fa91cab13469a2fc0055c783d06dbff125423e6bf510bfc9177e26e85e"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7c13b4cb0a0282560fe99d36f434bc13023aa8e0bb224dafc09931e8bbc6079a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7c13b4cb0a0282560fe99d36f434bc13023aa8e0bb224dafc09931e8bbc6079a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7c13b4cb0a0282560fe99d36f434bc13023aa8e0bb224dafc09931e8bbc6079a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4c3b9a5052e40814c6e6f77f2b1fa77c524109640c47dbe5b421362ca86c6073"
    sha256 cellar: :any,                 x86_64_linux:      "7a9dac93e83154d0bbbed852453de478678e0693f4f13a17d220baae5bf50a57"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Avoid building web UI
    ui_path = "internal/server/dist"
    mkdir_p ui_path
    (buildpath/"#{ui_path}/index.html").write "<!DOCTYPE html><html><body><h1>UI not built</h1></body></html>"

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/skillshare"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skillshare version")

    assert_match "config not found", shell_output("#{bin}/skillshare sync 2>&1", 1)
  end
end
