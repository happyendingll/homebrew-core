class Sqruff < Formula
  desc "Fast SQL formatter/linter"
  homepage "https://github.com/quarylabs/sqruff"
  url "https://github.com/quarylabs/sqruff/archive/refs/tags/v0.42.0.tar.gz"
  sha256 "88edddc02ac4bab9868651aa6a1bf18a997219693223c9f33a3a49e7c2cee553"
  license "Apache-2.0"
  head "https://github.com/quarylabs/sqruff.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "074918ccfc1c4a1123f3c3c17348f946fb124ca95358857001203c0e697a9d4c"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", "--bin", "sqruff", *std_cargo_args(path: "crates/cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sqruff --version")

    assert_match "AL01:	[aliasing.table]", shell_output("#{bin}/sqruff rules")

    (testpath/"test.sql").write <<~SQL
      SELECT * FROM user JOIN order ON user.id = order.user_id;
    SQL

    output = shell_output("#{bin}/sqruff lint --format human #{testpath}/test.sql 2>&1")
    assert_match "All Finished", output
  end
end
