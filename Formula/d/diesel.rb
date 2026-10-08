class Diesel < Formula
  desc "Command-line tool for Rust ORM Diesel"
  homepage "https://diesel.rs"
  url "https://static.crates.io/crates/diesel_cli/diesel_cli-2.3.14.crate"
  sha256 "0d10dbdcc7e8c4cb84e9ff9b1d6623b981395911b585e3bc753af9a31064c4bb"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/diesel-rs/diesel.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "6a9376b43ffb015186f980dbfab937a345232bf36b30e658765e281ede068d93"
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
