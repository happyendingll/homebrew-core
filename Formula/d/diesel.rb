class Diesel < Formula
  desc "Command-line tool for Rust ORM Diesel"
  homepage "https://diesel.rs"
  url "https://static.crates.io/crates/diesel_cli/diesel_cli-2.4.0.crate"
  sha256 "84223d1adcb1618dd0f68e7b309099d1323c59541eff336a8b83a7066edaae89"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/diesel-rs/diesel.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "b0430007b13373488a4b0c1f3d502ad6b831d41482756df8fc3cd5a659a685bd"
  end

  depends_on "rust" => [:build, :test]
  depends_on "libpq"
  depends_on "mariadb-connector-c"

  uses_from_macos "sqlite"

  deny_network_access!

  def fetch
    cd(build.head? ? "diesel_cli" : ".") do
      system "cargo", "generate-lockfile" if build.head?
      system "cargo", "fetch", *std_cargo_fetch_args
    end
  end

  def install
    system "cargo", "install", *std_cargo_args(path: build.head? ? "diesel_cli" : ".")
    generate_completions_from_executable(bin/"diesel", "completions")
  end

  test do
    ENV["DATABASE_URL"] = "db.sqlite"
    system "cargo", "init", "homebrew"
    cd "homebrew" do
      system bin/"diesel", "setup"
      assert_path_exists "db.sqlite", "SQLite database should be created"
    end
  end
end
