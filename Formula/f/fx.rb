class Fx < Formula
  desc "Terminal JSON viewer"
  homepage "https://fx.wtf"
  url "https://github.com/antonmedv/fx/archive/refs/tags/40.0.0.tar.gz"
  sha256 "92e5ade859952bc79a3c68492803ce0af25a7332c78c4a0e1914da302d88b478"
  license "MIT"
  head "https://github.com/antonmedv/fx.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d80a4b321b25fb303d2e0554bedf960fdcef2b2cbfae8dcd8470b1a6bf31b916"
  end

  depends_on "go" => :build

  conflicts_with "fx-agent", because: "both install an `fx` binary"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
    generate_completions_from_executable(bin/"fx", "--comp")
  end

  test do
    assert_equal "42", pipe_output("#{bin}/fx .", "42").strip
  end
end
