class CargoDist < Formula
  desc "Tool for building final distributable artifacts and uploading them to an archive"
  homepage "https://axodotdev.github.io/cargo-dist/"
  url "https://github.com/axodotdev/cargo-dist/archive/refs/tags/v0.34.0.tar.gz"
  sha256 "3bf0351c118f8f601a985c35f442ab7564eb4979bd9f8a6b6ef88bedf5d37675"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/axodotdev/cargo-dist.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "0911a1c51a2515efeb317ea07ad4d921786093be079184fa4f8e634f85b00567"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  conflicts_with "nmh", because: "both install `dist` binaries"

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "cargo-dist")
  end

  test do
    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    assert_match version.to_s, shell_output("#{bin}/dist --version")

    system "cargo", "new", "--bin", "test_project"
    cd "test_project" do
      output = shell_output("#{bin}/dist init 2>&1", 255)
      assert_match "added [profile.dist] to your workspace Cargo.toml", output

      output = shell_output("#{bin}/dist plan 2>&1", 255)
      assert_match "You specified --artifacts, disabling host mode, but specified no targets to build", output
    end
  end
end
