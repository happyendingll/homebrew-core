class SqlxCli < Formula
  desc "Command-line utility for SQLx, the Rust SQL toolkit"
  homepage "https://github.com/transact-rs/sqlx"
  url "https://static.crates.io/crates/sqlx-cli/sqlx-cli-0.9.0.crate"
  sha256 "93ef3857a4a0b48fcbf536b77a9122a35c7631686f2ccfbc75e616335771e8d0"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "7eec21e9fd10bd1ce532ae51986d90c6e4f8b9a6ed8bb315bbf2740f814daeff"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"sqlx", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sqlx --version")

    ENV["DATABASE_URL"] = "postgres://postgres@localhost/my_database"
    output = shell_output("#{bin}/sqlx migrate info 2>&1", 1)
    assert_match "error: while resolving migrations: error canonicalizing path migrations", output
  end
end
