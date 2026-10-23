class Fx < Formula
  desc "Terminal JSON viewer"
  homepage "https://fx.wtf"
  url "https://github.com/antonmedv/fx/archive/refs/tags/40.0.1.tar.gz"
  sha256 "311ca3f2ac2fe951c1f662b52e9fbf5ceeed74a2b7c52e8aa98c30001c2ffbb2"
  license "MIT"
  head "https://github.com/antonmedv/fx.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3a33ef5d46a3d80797237e561da528c9010f0e6bf5073a6a96bdc50d497063de"
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
