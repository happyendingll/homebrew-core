class ForgejoCli < Formula
  desc "CLI tool for interacting with Forgejo"
  homepage "https://codeberg.org/forgejo-contrib/forgejo-cli"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://codeberg.org/forgejo-contrib/forgejo-cli.git", branch: "main"

  stable do
    url "https://static.crates.io/crates/forgejo-cli/forgejo-cli-0.6.0.crate"
    sha256 "4d56acd6ab5caab2870d6e301cd6e42741ca98761fc1d5890dad09b21b44780e"

    # Fix issue with shell completions.
    # Remove with `stable` block with next release.
    patch do
      url "https://codeberg.org/forgejo-contrib/forgejo-cli/commit/42136622787b3a289b80565d2756263394dda855.patch"
      sha256 "f1ac36eb47411b1c11b1200de1750040a94f456b26655eeab1971c3767b28bec"
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "3364880792df537498daa8983eaad70545c0d60014f5b8f7e23e39125b4e797e"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"fj", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fj version")

    assert_match "Beyond coding. We forge.", shell_output("#{bin}/fj repo view codeberg.org/forgejo/forgejo")
  end
end
