class SqliteAnalyzer < Formula
  desc "Analyze how space is allocated inside an SQLite file"
  homepage "https://www.sqlite.org/"
  url "https://www.sqlite.org/2026/sqlite-src-3540100.zip"
  version "3.54.1"
  sha256 "387e7f6cad4797b17848c07d453dc6606917bb356a6cfe5a3abafd38c240c71b"
  license "blessing"

  livecheck do
    formula "sqlite"
  end

  no_autobump! because: :incompatible_version_format

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "bebe2101c97d49b928ae6696bbe3da2cc720a977128f6bd0a7e4ee718155d622"
  end

  deprecate! date: "2026-10-17", because: :deprecated_upstream

  disable! date: "2027-10-17", because: :deprecated_upstream

  depends_on "tcl-tk"

  uses_from_macos "sqlite" => :test

  on_macos do
    depends_on "libtommath"
  end

  # https://sqlite.org/draft/sqlanalyze.html

  def install
    system "./configure", "--with-tcl=#{formula_opt_lib("tcl-tk")}", *std_configure_args
    system "make", "sqlite3_analyzer"
    bin.install "sqlite3_analyzer"
  end

  test do
    dbpath = testpath/"school.sqlite"
    sqlpath = testpath/"school.sql"
    sqlpath.write <<~SQL
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
    SQL
    system "sqlite3 #{dbpath} < #{sqlpath}"
    system bin/"sqlite3_analyzer", dbpath
  end
end
