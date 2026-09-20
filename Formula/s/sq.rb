class Sq < Formula
  desc "Data wrangler with jq-like query language"
  homepage "https://sq.io"
  url "https://github.com/neilotoole/sq/archive/refs/tags/v0.55.0.tar.gz"
  sha256 "ab9f0595423269eacf43a531f1d101e296f100aabec95781dc8af6ab1c155739"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "9b8f81c0d1bc5cf07e45bf0a50dcdade50c1d6ca4d85867e18d8c08faead31cd"
  end

  depends_on "go" => :build

  uses_from_macos "sqlite" => :test

  conflicts_with "sequoia-sq", "squirrel-lang", because: "both install `sq` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    pkg = "github.com/neilotoole/sq/cli/buildinfo"
    ldflags = %W[
      -X #{pkg}.Version=v#{version}
      -X #{pkg}.Commit=RELEASE
      -X #{pkg}.Timestamp=#{time.iso8601}
    ]
    tags = %w[
      netgo sqlite_vtable sqlite_stat4 sqlite_fts5 sqlite_introspect
      sqlite_json sqlite_math_functions
    ]
    system "go", "build", *std_go_args(ldflags:, tags:)

    generate_completions_from_executable(bin/"sq", shell_parameter_format: :cobra)
    (man1/"sq.1").write Utils.safe_popen_read(bin/"sq", "man")
  end

  test do
    test_sql = <<~SQL
      create table t(a text, b integer);
      insert into t values ('hello',1),('there',42);
    SQL
    pipe_output("sqlite3 test.db", test_sql, 0)
    out1 = shell_output("#{bin}/sq add --active --handle @tst test.db")
    assert_equal %w[@tst sqlite3 test.db], out1.strip.split(/\s+/)
    out2 = shell_output("#{bin}/sq '@tst.t | .b' 2>&1")
    assert_equal %w[b 1 42], out2.strip.split("\n")
  end
end
