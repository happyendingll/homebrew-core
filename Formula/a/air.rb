class Air < Formula
  desc "Fast and opinionated formatter for R code"
  homepage "https://posit-dev.github.io/air/"
  url "https://github.com/posit-dev/air/archive/refs/tags/0.12.0.tar.gz"
  sha256 "8f74d4a64213718a1611a8da2afae1e8196558ad46d15205e869a6642be4c228"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d837be68455598724fa3a956d6ad79ea380997b9155e5478245e8e2c3b742c40"
  end

  depends_on "rust" => :build

  conflicts_with "go-air", because: "both install binaries with the same name"

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/air")

    generate_completions_from_executable(bin/"air", "generate-shell-completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    (testpath/"test.R").write <<~R
      # Simple R code for testing
      x<-1+2
      y <- 3 + 4
      print(x+y)
    R

    assert_match version.to_s, shell_output("#{bin}/air --version")

    system bin/"air", "format", testpath/"test.R"

    formatted_content = (testpath/"test.R").read
    assert_match "x <- 1 + 2", formatted_content
    assert_match "y <- 3 + 4", formatted_content
  end
end
