class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.54.tar.gz"
  sha256 "de5fe2e35e951e909d48e9054565eaf28eff7e899be7664ea114dad337ac551a"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "12295695e53e738e046b7c49e47bc9abaab34638d23fc81ce2dce0fc6136bf65"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "12295695e53e738e046b7c49e47bc9abaab34638d23fc81ce2dce0fc6136bf65"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "12295695e53e738e046b7c49e47bc9abaab34638d23fc81ce2dce0fc6136bf65"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d9fe6ce84f191a703f2184127ed45c9b517fa25c0f0909dbad1dddda331a7362"
    sha256 cellar: :any,                 x86_64_linux:      "5b6addf95bc2e0a588facf523ff6fbb466709d4fa544360c33e2547fc93c8eb7"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/zot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zot --version")
    assert_match "zot: no credential for anthropic", shell_output("#{bin}/zot rpc 2>&1", 1)
  end
end
