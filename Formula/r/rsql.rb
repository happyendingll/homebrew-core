class Rsql < Formula
  desc "CLI for relational databases and common data file formats"
  homepage "https://theseus-rs.github.io/rsql/rsql_cli/"
  url "https://github.com/theseus-rs/rsql/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "6b68d37931b47595aabb4d920be64dbd2042afa98b77d071f5db3930087da645"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/theseus-rs/rsql.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "b8ae654118d6363560c6534724d5d0a9775c7082308caa0f07d7225112a23bfc"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "rsql_cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rsql --version")

    # Create a sample CSV file
    (testpath/"data.csv").write <<~CSV
      name,age
      Alice,30
      Bob,25
      Charlie,35
    CSV

    query = "SELECT * FROM data WHERE age > 30"
    assert_match "Charlie", shell_output("#{bin}/rsql --url 'csv://#{testpath}/data.csv' -- '#{query}'")
  end
end
