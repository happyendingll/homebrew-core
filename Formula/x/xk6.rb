class Xk6 < Formula
  desc "Build k6 with extensions"
  homepage "https://k6.io"
  url "https://github.com/grafana/xk6/releases/download/v1.4.13/xk6_1.4.13_source.tar.gz"
  sha256 "175a48e236aa8d24a7b05782e35a8961f7774e8171fb6bbbd1aa19def5d2bfd7"
  license "Apache-2.0"
  head "https://github.com/grafana/xk6.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "52eba0b6be367dfd77325d9bb9aeb45ee88f7831686e84aacc950591389573a6"
  end

  depends_on "go"
  depends_on "gosec"
  depends_on "govulncheck"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X go.k6.io/xk6/internal/cmd.version=#{version}")
  end

  test do
    assert_match "xk6 version #{version}", shell_output("#{bin}/xk6 version")
    assert_match "xk6 has now produced a new k6 binary", shell_output("#{bin}/xk6 build")
    system bin/"xk6", "new", "github.com/grafana/xk6-testing"
    cd "xk6-testing" do
      system "git", "init"
      system "git", "add", "."
      system "git", "commit", "-m", "init commit"
      system "git", "tag", "v0.0.1"

      lint_output = shell_output("#{bin}/xk6 lint --disable=vulnerability")
      assert_match "✔ security", lint_output
      assert_match "✔ build", lint_output
    end
  end
end
