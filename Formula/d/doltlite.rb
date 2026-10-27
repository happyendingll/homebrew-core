class Doltlite < Formula
  desc "SQLite fork with Git-style version control via prolly trees"
  homepage "https://github.com/dolthub/doltlite"
  url "https://github.com/dolthub/doltlite/releases/download/v0.51.4/doltlite-autoconf-0.51.4.tar.gz"
  sha256 "473747661ddeac9203770b3872d6a70c0f13b8c088baec2e852dfecffbe2e0d4"
  license all_of: ["Apache-2.0", "blessing"]
  head "https://github.com/dolthub/doltlite.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "ad2cdc4de4eee6e093ff23d6dc839cc4c79ac0fc1c665500957d4352be762b3b"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    system "make", "doltlite", "doltlite-remotesrv", "doltlite-lib"
    # `make install` would also install `libsqlite3`, `sqlite3.h` and `sqlite3.1` from `sqlite`
    system "make", "install-shell-0", "install-doltlite-lib", "install-doltlite-headers"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/doltlite :memory: 'SELECT dolt_version();'")

    (testpath/"hello.c").write <<~'C'
      #include <stdio.h>
      #include "doltlite.h"
      int main(void) {
        sqlite3 *db;
        if (sqlite3_open(":memory:", &db) != SQLITE_OK) return 1;
        sqlite3_close(db);
        printf("ok\n");
        return 0;
      }
    C

    system ENV.cc, "hello.c", "-I#{include}", "-L#{lib}", "-ldoltlite", "-o", "hello"
    assert_equal "ok", shell_output("./hello").chomp
  end
end
