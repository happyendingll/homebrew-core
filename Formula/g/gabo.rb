class Gabo < Formula
  desc "Generates GitHub Actions boilerplate"
  homepage "https://ashishb.net/tech/common-pitfalls-of-github-actions/"
  url "https://github.com/ashishb/gabo/archive/refs/tags/v1.21.0.tar.gz"
  sha256 "674029ba6af49294147d7f5b3757d4e3eb0c5e0e23e44883410f7b233d678679"
  license "Apache-2.0"
  head "https://github.com/ashishb/gabo.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "4decdb17dcc6cb79895c9fede302e65dd472706deac347ec525c09c9f9d6e5c2"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download", "-C", "src/gabo"
  end

  def install
    cd "src/gabo" do
      system "go", "build", *std_go_args, "./cmd/gabo"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gabo --version")

    gabo_test = testpath/"gabo-test"
    gabo_test.mkpath
    (gabo_test/".git").mkpath # Emulate git
    system bin/"gabo", "-dir", gabo_test, "-for", "lint-yaml", "-mode=generate"
    assert_path_exists gabo_test/".github/workflows/lint-yaml.yaml"
  end
end
