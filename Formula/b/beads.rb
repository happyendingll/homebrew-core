class Beads < Formula
  desc "Memory upgrade for your coding agent"
  homepage "https://github.com/gastownhall/beads"
  url "https://github.com/gastownhall/beads/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "d2969ec18f4754dee4f08cb05a0d978dfcca750aa6db9a72b3f35ef3cd62dcc9"
  license "MIT"
  compatibility_version 1
  head "https://github.com/gastownhall/beads.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "451874012ea047b1c3a2b7b6fc25378643b51edebca01df615762ed1c08ea4ce"
    sha256 cellar: :any, arm64_tahoe:       "f28d2c348fd718849bb5aec116cd010dfcb38efe6c2dabdf0ea40c20a0a4800f"
    sha256 cellar: :any, arm64_sequoia:     "f517afe887886d2cbd4b4e4094da64f87368175eb03fb62f2b534724eeba08cc"
    sha256 cellar: :any, arm64_linux:       "f8deb72e06233457d6c8622d58b6f4332e1039c993cd175b9f5c9448634151ca"
    sha256 cellar: :any, x86_64_linux:      "282f488765da3665837ed32da8f91daf70531baeb55778d0bcc1a482367ea88c"
  end

  depends_on "go" => :build
  depends_on "dolt"
  depends_on "icu4c@78"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    if OS.linux? && Hardware::CPU.arm64?
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    ldflags = %W[
      -X main.Version=#{version}
      -X main.Build=#{tap.user}
      -X main.Branch=#{build.head? ? "HEAD" : "v#{version}"}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/bd"
    bin.install_symlink "beads" => "bd"

    generate_completions_from_executable(bin/"bd", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bd --version")

    system bin/"bd", "init", "--prefix", "homebrew-beads", "--non-interactive", "--stealth"
    system bin/"bd", "setup", "claude"
    assert_path_exists testpath/"CLAUDE.md"
    assert_path_exists testpath/".beads/config.yaml"

    output = shell_output("#{bin}/bd --db #{testpath}/.beads/dolt info")
    assert_match "Beads Database Information", output
    assert_match "Issue Count: 0", output
  end
end
