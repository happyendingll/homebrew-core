class Miniflux < Formula
  desc "Minimalist and opinionated feed reader"
  homepage "https://miniflux.app"
  url "https://github.com/miniflux/v2/archive/refs/tags/2.3.5.tar.gz"
  sha256 "1cd7bf4b2cf4a366271ee6cfa5994de3337fb13dc934d0eaf02e4b67839828d2"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "73ab675505a4494ebca1d813f44a695df6f2cb421fe1b12c2c1880830fa86af5"
  end

  depends_on "go" => :build
  depends_on "postgresql@18" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X miniflux.app/v2/internal/version.Version=#{version}
      -X miniflux.app/v2/internal/version.Commit=#{tap.user}
      -X miniflux.app/v2/internal/version.BuildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  service do
    run [opt_bin/"miniflux", "-c", etc/"miniflux.conf"]
    keep_alive true
    error_log_path var/"log/miniflux.log"
    log_path var/"log/miniflux.log"
    working_dir var
  end

  test do
    ENV["LC_ALL"] = "C"

    pg_port = free_port
    pg_bin = formula_opt_bin("postgresql@18")
    pg_ctl = pg_bin/"pg_ctl"

    datadir = testpath/"postgres"
    system pg_ctl, "init", "-D", datadir

    (datadir/"postgresql.conf").write <<~EOS, mode: "a+"
      port = #{pg_port}
      unix_socket_directories = '#{datadir}'
    EOS

    system pg_ctl, "start", "-D", datadir, "-l", testpath/"postgres.log"
    begin
      system pg_bin/"createdb", "-h", datadir, "-p", pg_port.to_s, "miniflux_test"

      # Run Miniflux
      miniflux_port = free_port
      (testpath/"miniflux.conf").write <<~CONF
        DATABASE_URL=postgres://localhost:#{pg_port}/miniflux_test?sslmode=disable
        ADMIN_USERNAME=admin
        ADMIN_PASSWORD=test123
        CREATE_ADMIN=1
        RUN_MIGRATIONS=1
        LOG_LEVEL=debug
        LISTEN_ADDR=127.0.0.1:#{miniflux_port}
      CONF

      miniflux_pid = spawn(bin/"miniflux", "-c", testpath/"miniflux.conf")
      begin
        assert_equal "OK",
          shell_output("curl --silent --retry 5 --retry-connrefused http://127.0.0.1:#{miniflux_port}/healthcheck")
      ensure
        Process.kill "TERM", miniflux_pid
        Process.wait miniflux_pid
      end
    ensure
      system pg_ctl, "stop", "-D", datadir
    end
  end
end
