class CargoDist < Formula
  desc "Tool for building final distributable artifacts and uploading them to an archive"
  homepage "https://axodotdev.github.io/cargo-dist/"
  url "https://github.com/axodotdev/cargo-dist/archive/refs/tags/v0.33.1.tar.gz"
  sha256 "b2d63c9dab0efb0400151e635ad42be94d4d70e51b930c60d97aecacff9588c9"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/axodotdev/cargo-dist.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ef1f048f39cf7d807e5f8270c6674fe53e7d5a647889034f5e6292d513d21f8c"
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
