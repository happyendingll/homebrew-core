class OpenCodeReview < Formula
  desc "AI-powered code review tool with deterministic pipelines and an LLM agent"
  homepage "https://open-codereview.ai"
  url "https://github.com/alibaba/open-code-review/archive/refs/tags/v1.12.3.tar.gz"
  sha256 "db9c2e290d9e56d727b6747109ff863915f7c3eb8497e12a223a67eeab1bc3ee"
  license "Apache-2.0"
  head "https://github.com/alibaba/open-code-review.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7c0b2e6478d0f1170b31523fd89ac3fcd791854ef4ee9a075ef11596715cd3b8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7c0b2e6478d0f1170b31523fd89ac3fcd791854ef4ee9a075ef11596715cd3b8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7c0b2e6478d0f1170b31523fd89ac3fcd791854ef4ee9a075ef11596715cd3b8"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "35632b53d785b34698cae1346113af3a2cd4b1ebb1af1a73ad576f61870637ec"
    sha256 cellar: :any,                 x86_64_linux:      "ee778f71fa33ee73b6fb52710b3a1cef580b9ab495b3333bc50ebf58dce86514"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"ocr"), "./cmd/opencodereview"
    generate_completions_from_executable(bin/"ocr", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocr --version")

    # "rules check" resolves which built-in review rule applies to a file.
    # It runs fully offline but expects to sit inside a git repo.
    system "git", "init", testpath
    (testpath/"main.go").write "package main\n"
    output = shell_output("#{bin}/ocr rules check main.go")
    assert_match "File: main.go", output
    assert_match "Pattern: **/*.go", output
    assert_match "Source: System built-in", output
  end
end
