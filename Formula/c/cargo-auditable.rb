class CargoAuditable < Formula
  desc "Make production Rust binaries auditable"
  homepage "https://github.com/rust-secure-code/cargo-auditable"
  url "https://github.com/rust-secure-code/cargo-auditable/archive/refs/tags/v0.7.6.tar.gz"
  sha256 "04cb1c742bdd2ed0ddbb0e05a89dba24a00391c9145ef357c23ff653eba8c166"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/rust-secure-code/cargo-auditable.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "c70bb2fd2c6e4442d55585ed5e66e5345a3fa9636f05bda0237776a50a850f53"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  def install
    system "cargo", "install", *std_cargo_args(path: "cargo-auditable")
    man1.install "cargo-auditable/cargo-auditable.1"
  end

  test do
    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    crate = testpath/"demo-crate"
    mkdir crate do
      (crate/"src/main.rs").write <<~RUST
        fn main() {
          println!("Hello BrewTestBot!");
        }
      RUST
      (crate/"Cargo.toml").write <<~TOML
        [package]
        name = "demo-crate"
        version = "0.1.0"
        license = "MIT"
      TOML

      system "cargo", "auditable", "build", "--release"
      assert_path_exists crate/"target/release/demo-crate"
      output = shell_output("./target/release/demo-crate")
      assert_match "Hello BrewTestBot!", output
    end
  end
end
