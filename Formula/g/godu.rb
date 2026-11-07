class Godu < Formula
  desc "Simple golang utility helping to discover large files/folders"
  homepage "https://github.com/viktomas/godu"
  url "https://github.com/viktomas/godu/archive/refs/tags/v1.5.2.tar.gz"
  sha256 "09869710652969b8a9d227dea4ac33893b1f538197b101affa6a8a9aa6a50474"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f554343c668ee65a187e05cf9de740a1001bbea2ed2d6248c4d8e06316ec4986"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # TODO: replace ldflags: value with :goreleaser once fix PR is merged
    # https://github.com/viktomas/godu/pull/106
    system "go", "build", *std_go_args(ldflags: "-X main.goduVersion=#{version}")
  end

  test do
    # godu is an interactive TUI app
    assert_equal "#{name} #{version}\n", shell_output("#{bin}/godu -v")
  end
end
