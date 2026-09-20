class Talm < Formula
  desc "Manage Talos Linux configurations the GitOps way"
  homepage "https://github.com/cozystack/talm"
  url "https://github.com/cozystack/talm/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "6b302b2e005374274c2d9ddea01355d291e4a77e3def5009bab8416458047c63"
  license "Apache-2.0"
  head "https://github.com/cozystack/talm.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "644d1ed1137fdd820d2b0428c68bea1b0a879b037dbcb31ebc993c0d61c89f98"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}")
    generate_completions_from_executable(bin/"talm", "completion")
  end

  test do
    assert_match "talm version #{version}", shell_output("#{bin}/talm --version")
    system bin/"talm", "init", "--name", "brew", "--preset", "generic"
    assert_path_exists testpath/"Chart.yaml"
  end
end
