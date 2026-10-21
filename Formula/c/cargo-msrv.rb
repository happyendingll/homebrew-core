class CargoMsrv < Formula
  desc "Find the minimum supported Rust version (MSRV) for your project"
  homepage "https://foresterre.github.io/cargo-msrv"
  url "https://github.com/foresterre/cargo-msrv/archive/refs/tags/v0.19.5.tar.gz"
  sha256 "b9b208bc8f7c91e01ff792b442b9ef972ed923573d862da3e3560cf975404e7e"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/foresterre/cargo-msrv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2ce5d680542f3a65d6adef50072543de44b67b691c9f9422fdd3401904378f7e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8e429e8298a5ed4a89c97ba0070333d011b09eef24e494f310ffc79243c00a11"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5e304cab01987534820116df57bff460ab2f8c6bb1d866a2cad112536aa0f251"
    sha256 cellar: :any,                 arm64_linux:       "1204e8fed633f0bb52992f0bed6e29ff7a98a269ea7bd2355827df5d412866c0"
    sha256 cellar: :any,                 x86_64_linux:      "832808aee0d9ad0364979f06a374cf60421f557a18d34e07b71aa9b8e369753d"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV["NO_COLOR"] = "1"

    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    assert_match version.to_s, shell_output("#{bin}/cargo-msrv --version")

    # Now proceed with creating your crate and calling cargo-msrv
    (testpath/"demo-crate/src").mkpath
    (testpath/"demo-crate/src/main.rs").write "fn main() {}"
    (testpath/"demo-crate/Cargo.toml").write <<~TOML
      [package]
      name = "demo-crate"
      version = "0.1.0"
      edition = "2021"
      rust-version = "1.78"
    TOML

    cd "demo-crate" do
      output = shell_output("#{bin}/cargo-msrv msrv show --output-format human --log-target stdout 2>&1")
      assert_match "name: \"demo-crate\"", output
    end
  end
end
