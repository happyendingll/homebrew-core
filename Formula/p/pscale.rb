class Pscale < Formula
  desc "CLI for PlanetScale Database"
  homepage "https://www.planetscale.com/"
  url "https://github.com/planetscale/cli/archive/refs/tags/v0.331.0.tar.gz"
  sha256 "7e480dcb881045d0aaae55934367aa9328be2b8c8ca1406c181afb2d9834dac9"
  license "Apache-2.0"
  head "https://github.com/planetscale/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a131dc1df6f2a343c06cd5a0b0ac57d79826e344eca1594cb15d465f1d570ced"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "99ebf29d1666894540d915f1550c8bd38399719233d381bed7f485dbf2afedd7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9f1c14ee84a65a2af8bf0d876360986085f34cdb97e5fa4a8773b691818ace21"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "76f53e75832c58d85dce0fd2589e859fc70cbc3fd7ee9777f672568c88c8077b"
    sha256 cellar: :any,                 x86_64_linux:  "45107bf793f09ef93e8f10fc97760db8358d0754d487250f0f9347341417e8ca"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/pscale"

    generate_completions_from_executable(bin/"pscale", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pscale version")

    assert_match "Error: not authenticated yet", shell_output("#{bin}/pscale org list 2>&1", 2)
  end
end
