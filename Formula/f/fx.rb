class Fx < Formula
  desc "Terminal JSON viewer"
  homepage "https://fx.wtf"
  url "https://github.com/antonmedv/fx/archive/refs/tags/40.0.2.tar.gz"
  sha256 "1bfb6664c0adba8ff12618e7dd9334921f3c9e5e41c7724027c0949fce826347"
  license "MIT"
  head "https://github.com/antonmedv/fx.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "2aa01bd39e6ee81b7bc5893d55b19a00abb3534a01e7150fdc3735f751669939"
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
