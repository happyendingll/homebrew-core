class Ekphos < Formula
  desc "Terminal-based markdown research tool inspired by Obsidian"
  homepage "https://ekphos.netlify.app/docs"
  url "https://github.com/hanebox/ekphos/archive/refs/tags/v0.50.0.tar.gz"
  sha256 "fe42ee4e01b31041d2813c91d88271f3cebbd0d16cc79eebce9a1289dbecbcea"
  license "MIT"
  head "https://github.com/hanebox/ekphos.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "2e2bf4fa0fb3a85e7ca9f6bfe4e3bd4eff7b4d35646d3a9f9bcee00f350ddc3c"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # ekphos is a TUI application
    assert_match version.to_s, shell_output("#{bin}/ekphos --version")

    assert_match "Resetting ekphos configuration...", shell_output("#{bin}/ekphos --reset")
  end
end
