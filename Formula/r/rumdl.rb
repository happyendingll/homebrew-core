class Rumdl < Formula
  desc "Markdown Linter and Formatter written in Rust"
  homepage "https://github.com/rvben/rumdl"
  url "https://github.com/rvben/rumdl/archive/refs/tags/v0.2.70.tar.gz"
  sha256 "58c04059f24ef646c4322da855e3251355d5b151dba33a0096b51fa227f40012"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "248a4b1722dabc3cb5bb406c937c38a4f59923f84658451740419419d89db04a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3862e1bb7f81a639061b768ed4ef3825d164f0c452063eb4653bfb0de6e6d865"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e119c72458ceb5a71cbc10017500918a6466eee9eaa53b0070eabdbb275f9da3"
    sha256 cellar: :any,                 arm64_linux:   "6dd2e12987177a60ac97ff34ec9cc8b6a3d0b11a3a905cbb18e93e586d6f8f5a"
    sha256 cellar: :any,                 x86_64_linux:  "32732795ca864b25f1b7fc748d5d17687986313ee87b0dc96dd28b7e04b6446e"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"rumdl", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rumdl version")

    (testpath/"test-bad.md").write <<~MARKDOWN
      # Header 1
      body
    MARKDOWN
    (testpath/"test-good.md").write <<~MARKDOWN
      # Header 1

      body
    MARKDOWN

    assert_match "Success", shell_output("#{bin}/rumdl check test-good.md")
    assert_match "MD022", shell_output("#{bin}/rumdl check test-bad.md 2>&1", 1)
    assert_match "Fixed", shell_output("#{bin}/rumdl fmt test-bad.md")
    assert_equal (testpath/"test-good.md").read, (testpath/"test-bad.md").read
  end
end
