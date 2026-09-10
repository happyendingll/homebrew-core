class Render < Formula
  desc "Command-line interface for Render"
  homepage "https://render.com/docs/cli"
  url "https://github.com/render-oss/cli/archive/refs/tags/v2.27.0.tar.gz"
  sha256 "6653ef7bce742c4e44dedc30aebd69bffc8e1a4565352589d44fd913489d4f7b"
  license "Apache-2.0"
  head "https://github.com/render-oss/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "ea1ef0fba78476a69802b911df31285b863da59d0dd458d61c321ee4fb028044"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ea1ef0fba78476a69802b911df31285b863da59d0dd458d61c321ee4fb028044"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ea1ef0fba78476a69802b911df31285b863da59d0dd458d61c321ee4fb028044"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7b477c5d9a043263d1340a26fcfacbde514428ac0165c00bca3a3f48e8edb187"
    sha256 cellar: :any,                 x86_64_linux:  "f5b0a87e88437df8f640945154f3ce7d44db8b63df276e83f7655df2a3a037a5"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[-X github.com/render-oss/cli/pkg/cfg.Version=#{version}]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/render --version")

    output = shell_output("#{bin}/render services -o json 2>&1", 1)
    assert_match "Error: no workspace set. Use `render workspace set` to set a workspace", output
  end
end
