class Tsuzuri < Formula
  desc "Block-based Markdown notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "9fb1a7ffe01471db44747db60591c8d6072c29639d6409213241bf13be2db796"
  license "MIT"
  head "https://github.com/jaisuriya-11/tsuzuri.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "9a1061739ed8d697971d0cfe3ff123fd0d42dd5e29ae2f3c541a4065300537a4"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/tsuzuri"
  end

  test do
    assert_match "tsuzuri #{version}", shell_output("#{bin}/tsuzuri --version")

    (testpath/"note.md").write <<~MARKDOWN
      # Homebrew

      A notebook with **bold text** and a list:

      - First item
      - Second item
    MARKDOWN
    system bin/"tsuzuri", "export", "note.md"
    pdf = (testpath/"note.pdf").binread
    assert_match(/\A%PDF-/, pdf)
    assert_match "/Type /Page", pdf
  end
end
