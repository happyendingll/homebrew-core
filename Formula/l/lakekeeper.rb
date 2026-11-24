class Lakekeeper < Formula
  desc "Apache Iceberg REST Catalog"
  homepage "https://docs.lakekeeper.io"
  url "https://github.com/lakekeeper/lakekeeper/archive/refs/tags/v0.15.1.tar.gz"
  sha256 "8d8e0bd868aa718d1a0e10d1d2ce6ab6dde363ecaf781ab25c512e67ce895e67"
  license "Apache-2.0"
  head "https://github.com/lakekeeper/lakekeeper.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "ff84f8de26cdc664b049a2e05b7802520b0ca1a91d9c12139bd0521ac8c48992"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "postgresql@19" => :test
  depends_on "openssl@4"

  uses_from_macos "llvm" => :build # for libclang

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = dep("openssl").opt_prefix

    system "cargo", "install", *std_cargo_args(path: "crates/lakekeeper-bin")
  end

  test do
    ENV["LC_ALL"] = "C"
    ENV["PGDATA"] = testpath/"test"

    postgresql = dep("postgresql").name
    pg_ctl = formula_opt_bin(postgresql)/"pg_ctl"
    port = free_port

    system pg_ctl, "initdb", "--options=-E UTF-8 -U postgres -c port=#{port}"
    system pg_ctl, "start", "--log=#{testpath}/log"

    with_env(LAKEKEEPER__PG_DATABASE_URL_WRITE: "postgres://postgres@localhost:#{port}/postgres") do
      assert_match "Database migration complete", shell_output("#{bin}/lakekeeper migrate")
    ensure
      system pg_ctl, "stop"
    end
  end
end
