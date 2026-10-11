class Pgroonga < Formula
  desc "PostgreSQL plugin to use Groonga as index"
  homepage "https://pgroonga.github.io/"
  url "https://packages.groonga.org/source/pgroonga/pgroonga-4.1.0.tar.gz"
  sha256 "0ce8d58e73820bb74e82882afa58d6c0c5c46d43ae8349c6fc05c7097b85ee40"
  license "PostgreSQL"

  livecheck do
    url "https://pgroonga.github.io/install/source.html"
    regex(/pgroonga[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "c70d5a9b9c89627f7778a47a18640caeb48578215b11e18f62dbb9434d9d926d"
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
