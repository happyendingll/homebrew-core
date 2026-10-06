class Lazysql < Formula
  desc "Cross-platform TUI database management tool"
  homepage "https://github.com/jorgerojas26/lazysql"
  url "https://github.com/jorgerojas26/lazysql/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "7f3c7d7838e3bd492261f992a5941debe22b2c4ba7e12faa4f8be040079986ac"
  license "MIT"
  head "https://github.com/jorgerojas26/lazysql.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "637b396a87503a7be79a447973d70338c6e9e6c312f3b05c61a76bfb653ce1ad"
  end

  depends_on "go" => :build
  uses_from_macos "sqlite" => :test

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    school = <<~SQL
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    SQL

    names = pipe_output("sqlite3 test.db", school, 0).strip.split("\n")
    assert_equal %w[Sue Tim Bob], names

    assert_match "terminal not cursor addressable", shell_output("#{bin}/lazysql test.db 2>&1", 1)

    assert_match version.to_s, shell_output("#{bin}/lazysql -version 2>&1")
  end
end
