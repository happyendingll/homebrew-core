class Kyua < Formula
  desc "Testing framework for infrastructure software"
  homepage "https://github.com/freebsd/kyua"
  url "https://github.com/freebsd/kyua/releases/download/kyua-0.15.1/kyua-0.15.1.tar.gz"
  sha256 "19adf19c1cce83b0484ee786ff813a1745e2aa4c2e1a0cceefb41da91c43c87c"
  license "BSD-3-Clause"
  head "https://github.com/freebsd/kyua.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 sequoia: "362505ff92c2f6bffbe188701022a86df40ebf5ef84f798dc946b26e9c3250ed"
  end

  depends_on "pkgconf" => [:build, :test]
  depends_on "atf"
  depends_on "lua"
  depends_on "lutok"

  uses_from_macos "sqlite"

  deny_network_access!

  def install
    ENV.append "CPPFLAGS", "-I#{formula_opt_include("lua")}/lua"

    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--enable-atf"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    kyuafile = testpath/"Kyuafile"
    kyuafile.write <<~KYUA
      syntax(2)

      test_suite("sanity_check")

      atf_test_program{name="atf_test"}
      plain_test_program{name="plain_test"}
      tap_test_program{name="tap_test"}
    KYUA

    atf_test_c = testpath/"atf_test.c"
    atf_test_c.write <<~C
      #include <atf-c.h>

      ATF_TC_WITHOUT_HEAD(tc1);
      ATF_TC_BODY(tc1, tc)
      {
        int i = 2;
        ATF_REQUIRE_EQ(i * 2, 4);
      }

      ATF_TP_ADD_TCS(tp)
      {
        ATF_TP_ADD_TC(tp, tc1);

        return atf_no_error();
      }
    C

    flags = shell_output("pkgconf --cflags --libs atf-c").chomp.split
    system ENV.cc, atf_test_c, "-o", "atf_test", *flags

    plain_test = testpath/"plain_test"
    plain_test.write <<~SH
      #!/bin/sh
      echo "this is a plain test that always passes"
    SH
    plain_test.chmod(0555)

    tap_test = testpath/"tap_test"
    tap_test.write <<~SH
      #!/bin/sh
      echo "1..2"
      echo "ok 1"
      echo "not ok 2 # SKIP: demonstrates that not ok + SKIP => does not fail"
    SH
    tap_test.chmod(0555)

    system bin/"kyua", "test", "-k", kyuafile
  end
end
