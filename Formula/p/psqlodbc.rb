class Psqlodbc < Formula
  desc "Official PostgreSQL ODBC driver"
  homepage "https://odbc.postgresql.org"
  url "https://github.com/postgresql-interfaces/psqlodbc/archive/refs/tags/REL-18_00_0007.tar.gz"
  sha256 "421215067d91152b10d3b7e251de1d02d627766e3c99ca2ed9065a7babca7a85"
  license "LGPL-2.0-or-later"
  head "https://github.com/postgresql-interfaces/psqlodbc.git", branch: "main"

  livecheck do
    url :stable
    regex(/^REL[._-]?v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "e2d4279bdb5d11e7bec1218a0bb595f190604a5b3e1f77581f7399c847182d31"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libpq"
  depends_on "unixodbc"

  deny_network_access!

  def install
    system "./bootstrap"
    system "./configure", "--prefix=#{prefix}",
                          "--with-unixodbc=#{formula_opt_prefix("unixodbc")}"
    system "make"
    system "make", "install"
  end

  test do
    output = shell_output("#{formula_opt_bin("unixodbc")}/dltest #{lib}/psqlodbcw.so")
    assert_equal "SUCCESS: Loaded #{lib}/psqlodbcw.so\n", output
  end
end
