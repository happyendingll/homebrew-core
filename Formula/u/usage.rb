class Usage < Formula
  desc "Tool for working with usage-spec CLIs"
  homepage "https://usage.jdx.dev/"
  url "https://github.com/jdx/usage/archive/refs/tags/v7.0.0.tar.gz"
  sha256 "3fae306ebe59272568459dc9cb2c289225f47513922998ac1af81190736c2ee0"
  license "MIT"
  compatibility_version 1
  head "https://github.com/jdx/usage.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "628bf72417b76e06e6566649bc663c8f7a32c39a401d586d3464e3432f71d6cb"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a4d8c3f1af9be30c06ba872492b68d7e1f1a87389069aab2b8053296e0f99de6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3f0f5b1ccd002c5ec6d1e7cf95bbd2a17b77b963162b850be7c05dcbcee3e4fd"
    sha256 cellar: :any,                 arm64_linux:       "bbbf7c3a2bce090701b2092024842e9b676439ee046012c3f12e1718efaf13c6"
    sha256 cellar: :any,                 x86_64_linux:      "c9cd4c80988ebad0631a9d1f92baab635b51cd8e713178dfd7ef3045a0d539df"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "cli")
    man1.install "cli/assets/usage.1"
    generate_completions_from_executable(bin/"usage", "--completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/usage --version").chomp
    assert_equal "--foo", shell_output("#{bin}/usage complete-word --spec 'flag \"--foo\"' -").chomp
  end
end
