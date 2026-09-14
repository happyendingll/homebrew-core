class Checkmake < Formula
  desc "Linter/analyzer for Makefiles"
  homepage "https://github.com/checkmake/checkmake"
  url "https://github.com/checkmake/checkmake/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "450412ba6500ef7c4c8a0150a5e1a3d2e76591ce9f37609bcbd5508298ad9bef"
  license "MIT"
  head "https://github.com/checkmake/checkmake.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "e4f938a0f50939f663c62360a9ddf4a0a568f42bb7184583a2c4b1291a227a1d"
  end

  depends_on "go" => :build
  depends_on "pandoc" => :build

  def install
    ENV["BUILDER_NAME"] = "Homebrew"
    ENV["BUILDER_EMAIL"] = "homebrew@brew.sh"
    ENV["PREFIX"] = prefix
    # The default target runs an unpinned `golangci-lint@latest`, whose new checks fail on the test files
    system "make", "install", "VERSION=#{version}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/checkmake --version")

    sh = testpath/"Makefile"
    sh.write <<~EOS
      clean:
      \trm bar
      \trm foo

      foo: bar
      \ttouch foo

      bar:
      \ttouch bar

      all: foo

      test:
      \t@echo test

      .PHONY: clean test
    EOS
    assert_match "phonydeclared", shell_output("#{bin}/checkmake #{sh}", 1)
  end
end
