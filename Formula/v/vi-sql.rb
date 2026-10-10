class ViSql < Formula
  desc "Terminal UI for SQL databases"
  homepage "https://vi-sql.com"
  url "https://github.com/kopecmaciej/vi-sql/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "97cb4db898f70f17488b601180e3c246aff494172c6282b5a5852c6f620c795f"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9d324d9d55b87030a8a632a823278f1079b4a9746f95aa6ac09566f59b1a1e99"
  end

  depends_on "go" => :build

  uses_from_macos "sqlite" => :test

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X github.com/kopecmaciej/vi-sql/internal/build.Version=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vi-sql --version")

    test_db = testpath/"test.db"
    sql = <<~SQL
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    SQL

    assert_match "Tim", pipe_output("sqlite3 #{test_db}", sql)

    ENV["TERM"] = "xterm"
    output_log = testpath/"output.log"

    require "expect"
    require "pty"
    PTY.spawn(bin/"vi-sql", "--reset-master-password", "--connect", "file:#{test_db}", "--jump", "main.students",
              [:out, :err] => output_log.to_s) do |r, w, pid|
      r.expect "SQL Editor Normal", 5
      w.write "\x03"
      sleep 2
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    ensure
      r.close
      w.close
      Process.wait(pid)
    end

    assert_match "Master password is not configured", output_log.read
  end
end
