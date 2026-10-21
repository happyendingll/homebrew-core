class Ggc < Formula
  desc "Modern Git CLI"
  homepage "https://github.com/bmf-san/ggc"
  url "https://github.com/bmf-san/ggc/archive/refs/tags/v8.7.6.tar.gz"
  sha256 "b524691a42dbb5fe06bcadfca05d18bd69ce472ca9a2116181b727a1a5cb0158"
  license "MIT"
  head "https://github.com/bmf-san/ggc.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2fba7e55a3158a48cd0f5ae969a96c248bceec36374eeda913a35086394b9d48"
  end

  depends_on "go" => :build

  uses_from_macos "vim"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ggc version")
    assert_equal "main", shell_output("#{bin}/ggc config get default.branch").chomp
  end
end
