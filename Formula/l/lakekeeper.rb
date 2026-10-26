class Lakekeeper < Formula
  desc "Apache Iceberg REST Catalog"
  homepage "https://docs.lakekeeper.io"
  url "https://github.com/lakekeeper/lakekeeper/archive/refs/tags/v0.14.2.tar.gz"
  sha256 "663f893060bb0fe27c4beeaceff0f5ab96aea0d1c32c235227bffdab5a927e92"
  license "Apache-2.0"
  head "https://github.com/lakekeeper/lakekeeper.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "7871ed3f5b7878c49b2755070b86ea7b7153b2f77f66bebc62853da1fde1f198"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "postgresql@18" => :test
  depends_on "openssl@4"

  uses_from_macos "llvm" => :build # for libclang

  allow_network_access! :test

  def openssl = deps.map(&:name).find { |d| d.match?(/^openssl(@\d+(\.\d+)*)?$/) }

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix(openssl)

    system "cargo", "install", *std_cargo_args(path: "crates/lakekeeper-bin")
  end

  test do
    ENV["LC_ALL"] = "C"

    postgresql = deps.map(&:name).find { |d| d.match?(/^postgresql(@\d+(\.\d+)*)?$/) }
    pg_ctl = formula_opt_bin(postgresql)/"pg_ctl"
    port = free_port

    system pg_ctl, "initdb", "-D", testpath/"test", "-o", "-E UTF-8 -U postgres"
    (testpath/"test/postgresql.conf").write <<~EOS, mode: "a+"
      port = #{port}
    EOS
    system pg_ctl, "start", "-D", testpath/"test", "-l", testpath/"log"

    begin
      ENV["LAKEKEEPER__PG_DATABASE_URL_WRITE"] = "postgres://postgres@localhost:#{port}/postgres"
      output = shell_output("#{bin}/lakekeeper migrate")
      assert_match "Database migration complete", output
    ensure
      system pg_ctl, "stop", "-D", testpath/"test"
    end
  end
end
