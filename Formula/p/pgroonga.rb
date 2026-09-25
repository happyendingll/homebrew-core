class Pgroonga < Formula
  desc "PostgreSQL plugin to use Groonga as index"
  homepage "https://pgroonga.github.io/"
  url "https://packages.groonga.org/source/pgroonga/pgroonga-4.0.9.tar.gz"
  sha256 "7d9fd0d8380ef0e807683c30ea25934e0bf5cfdc9553ad17a5907b620e0cbf72"
  license "PostgreSQL"

  livecheck do
    url "https://pgroonga.github.io/install/source.html"
    regex(/pgroonga[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "b02a9bd18c1d333a0e056f1e38b96de11b4538795d96be38119c5af1fbe80190"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "postgresql@17" => [:build, :test]
  depends_on "postgresql@18" => [:build, :test]
  depends_on "groonga"
  depends_on "msgpack"
  depends_on "xxhash"

  deny_network_access!

  def postgresqls
    deps.map(&:to_formula).sort_by(&:version).filter { |f| f.name.start_with?("postgresql@") }
  end

  def install
    odie "Too many postgresql dependencies!" if postgresqls.count > 2

    postgresqls.each do |postgresql|
      with_env(PATH: "#{postgresql.opt_bin}:#{ENV["PATH"]}") do
        args = %W[
          -Dinstall_to_postgresql=false
          -Dtest=false
          --prefix=#{prefix}
          --bindir=#{bin}
          --libdir=#{lib/postgresql.name}
          --datadir=#{share/postgresql.name}
          --buildtype=release
          --wrap-mode=nofallback
        ]

        system "meson", "setup", "build", *args
        system "meson", "compile", "-C", "build", "--verbose"
        system "meson", "install", "-C", "build"
      end
    end
  end

  test do
    ENV["LC_ALL"] = "C"
    postgresqls.each do |postgresql|
      pg_ctl = postgresql.opt_bin/"pg_ctl"
      psql = postgresql.opt_bin/"psql"

      datadir = testpath/postgresql.name
      system pg_ctl, "initdb", "-D", datadir
      (datadir/"postgresql.conf").write <<~CONF, mode: "a+"
        listen_addresses = ''
        unix_socket_directories = '#{testpath}'
      CONF
      system pg_ctl, "start", "-D", datadir, "-l", testpath/"log-#{postgresql.name}"
      begin
        system psql, "-h", testpath, "-c", "CREATE EXTENSION \"pgroonga\";", "postgres"
      ensure
        system pg_ctl, "stop", "-D", datadir
      end
    end
  end
end
