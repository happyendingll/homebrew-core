class Scilla < Formula
  desc "DNS, subdomain, port, directory enumeration tool"
  homepage "https://edoardottt.com/"
  url "https://github.com/edoardottt/scilla/archive/refs/tags/v1.3.4.tar.gz"
  sha256 "f1a738745a2b45aa1dd37e1754a186bc08fb186f01e241257c7ae5a176eb7d44"
  license "GPL-3.0-or-later"
  head "https://github.com/edoardottt/scilla.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c27a8412260ea50e14b508d881fc994b173bfe53e12d3bb58a286835717b145b"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/scilla"
  end

  test do
    output = shell_output("#{bin}/scilla dns -target brew.sh")
    assert_match <<~EOS, output
      =====================================================
      target: brew.sh
      ================ SCANNING DNS =======================
    EOS

    assert_match version.to_s, shell_output("#{bin}/scilla --help 2>&1", 1)
  end
end
