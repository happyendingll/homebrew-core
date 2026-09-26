class Fallow < Formula
  desc "Codebase intelligence for TypeScript and JavaScript"
  homepage "https://docs.fallow.tools"
  url "https://github.com/fallow-rs/fallow/archive/refs/tags/v3.29.0.tar.gz"
  sha256 "7e37778c6b1fba484f0780540be0af75475dde4e82331faa961474573e542167"
  license "MIT"
  head "https://github.com/fallow-rs/fallow.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ac35135993cbfa2852d6366447508fc55caad8daea4ed5ecd67484efe707082a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "18d35c94fa2d19c958aed149cadacc27f36dc64cce2701e117b0ed4b8b44090e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6e80c498488282b090336f9d611d393a79e7b53c4169c35b1e451e4c5fd33dbe"
    sha256 cellar: :any,                 arm64_linux:       "4356ac16b96d3a12ddf8225d49c89904a0265232f4c898e03893e09058d2ca8d"
    sha256 cellar: :any,                 x86_64_linux:      "907fecb503b7c1323860a19f5935b782a89b88edc1ad244992dbb635413a7a4b"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cli")
  end

  test do
    (testpath/"package.json").write <<~JSON
      {
        "scripts": {
          "start": "node src/index.js"
        },
        "dependencies": {}
      }
    JSON

    (testpath/"node_modules").mkpath
    (testpath/"src").mkpath
    (testpath/"src/index.js").write <<~JS
      export const used = 1;
      console.log(used);
    JS
    (testpath/"src/unused.js").write <<~JS
      export const unused = 1;
    JS

    system "git", "init", "-q"

    output = JSON.parse(shell_output("#{bin}/fallow --format json --quiet --no-cache"))
    assert_equal 1, output.dig("check", "summary", "unused_files")
    assert_kind_of Hash, output.fetch("dupes")
    assert_kind_of Numeric, output.dig("health", "vital_signs", "dead_file_pct")
    assert_match version.to_s, shell_output("#{bin}/fallow --version")
  end
end
