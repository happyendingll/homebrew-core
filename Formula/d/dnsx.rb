class Dnsx < Formula
  desc "DNS query and resolution tool"
  homepage "https://github.com/projectdiscovery/dnsx"
  url "https://github.com/projectdiscovery/dnsx/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "2c14a27b00e3215e1c0dc07afe9e5e5c3f0a3502852f1d5f497a92b5e6cb63db"
  license "MIT"
  head "https://github.com/projectdiscovery/dnsx.git", branch: "dev"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "0f88bf5e5086ea888ad86ddd075efe04b3f072c66416500fb4b785000e765790"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/dnsx"
  end

  test do
    (testpath/"domains.txt").write "docs.brew.sh"
    expected_output = "docs.brew.sh [CNAME] [homebrew.github.io]"
    assert_equal expected_output,
      shell_output("#{bin}/dnsx -no-color -silent -l #{testpath}/domains.txt -cname -resp").strip
  end
end
