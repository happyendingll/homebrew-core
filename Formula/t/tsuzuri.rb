class Tsuzuri < Formula
  desc "Block-based Markdown notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "1b1b9cf58e70a3e74d84eda68976213eaf1a2db8f43e08658f136057ab8bbe04"
  license "MIT"
  head "https://github.com/jaisuriya-11/tsuzuri.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "973ccbf1a297d7acaa0b5dd196e8665b960feaadb802bcc88ce575e76bcada74"
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
