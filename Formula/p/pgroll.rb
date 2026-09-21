class Pgroll < Formula
  desc "Postgres zero-downtime migrations made easy"
  homepage "https://pgroll.com"
  url "https://github.com/xataio/pgroll/archive/refs/tags/v0.16.3.tar.gz"
  sha256 "28531c0021773e82867c7d0df8859d4fc2eadfc444c6e451f39c58265c9c2a69"
  license "Apache-2.0"
  head "https://github.com/xataio/pgroll.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "946ffb7bd8bd2e768908b2cf49b074c529a5da8641fdf4ab4e82700b84c760ce"
  end

  depends_on "go" => :build
  depends_on "postgresql@18" => :test
  depends_on "libpg_query"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1"

    ldflags = "-X github.com/xataio/pgroll/cmd.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"pgroll", shell_parameter_format: :cobra)

    pkgshare.install "examples/01_create_tables.yaml"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pgroll --version")

    cp_r pkgshare/"01_create_tables.yaml", testpath
    ENV["LC_ALL"] = "C"

    postgresql = Formula["postgresql@18"]
    pg_ctl = postgresql.opt_bin/"pg_ctl"
    port = free_port

    system pg_ctl, "initdb", "-D", testpath/"test"
    (testpath/"test/postgresql.conf").write <<~EOS, mode: "a+"
      port = #{port}
    EOS
    system pg_ctl, "start", "-D", testpath/"test", "-l", testpath/"log"

    begin
      pg_uri = "postgres://#{ENV["USER"]}@localhost:#{port}/postgres?sslmode=disable"

      system bin/"pgroll", "init", "--postgres-url", pg_uri
      system bin/"pgroll", "--postgres-url", pg_uri, "start", "01_create_tables.yaml"

      status_output = shell_output("#{bin}/pgroll --postgres-url #{pg_uri} status")
      assert_match "01_create_tables", status_output

      complete_output = shell_output("#{bin}/pgroll --postgres-url #{pg_uri} complete 2>&1")
      assert_match "Migration successful", complete_output
    ensure
      system pg_ctl, "stop", "-D", testpath/"test"
    end
  end
end
