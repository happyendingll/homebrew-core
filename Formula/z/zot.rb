class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.3.87.tar.gz"
  sha256 "9279f56fb2d40ff110f14e464a4f939e7fef9d1688494426eeac424b04494a17"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "6d32b18fc375bcd05763c8c9d7fceff06b23a9d68df4235ddf337b766d9bad02"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6d32b18fc375bcd05763c8c9d7fceff06b23a9d68df4235ddf337b766d9bad02"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6d32b18fc375bcd05763c8c9d7fceff06b23a9d68df4235ddf337b766d9bad02"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "6b525b69d770b04d7dd7e7604daa115f0cf1366fb65f38f889cfb53cc850fdef"
    sha256 cellar: :any,                 x86_64_linux:      "d19f333a7af420420e0bc537efbf69ceb2b9b0e63363610281b4332bc045450e"
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
