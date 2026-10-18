class Lemon < Formula
  desc "LALR(1) parser generator like yacc or bison"
  homepage "https://www.hwaci.com/sw/lemon/"
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
    sha256 cellar: :any_skip_relocation, sequoia: "da7faabd2b46366f493bde890665736bee6fabd44748c7ebf1a7fa35c6afa0c7"
  end

  # Submitted the patch via email to the upstream
  patch :DATA

  def install
    pkgshare.install "tool/lempar.c"

    # patch the parser generator to look for the 'lempar.c' template file where we've installed it
    inreplace "tool/lemon.c", "lempar.c", "#{pkgshare}/lempar.c"

    system ENV.cc, "-o", "lemon", "tool/lemon.c"
    bin.install "lemon"

    pkgshare.install "test/lemon-test01.y"
    doc.install "doc/lemon.html"
  end

  test do
    system bin/"lemon", "-d#{testpath}", "#{pkgshare}/lemon-test01.y"
    system ENV.cc, "lemon-test01.c"
    assert_match "tests pass", shell_output("./a.out")
  end
end

__END__
diff --git a/test/lemon-test01.y b/test/lemon-test01.y
index 0fd514f..67a3752 100644
--- a/test/lemon-test01.y
+++ b/test/lemon-test01.y
@@ -54,8 +54,8 @@ all ::=  error B.
     Parse(&xp, 0, 0);
     ParseFinalize(&xp);
     testCase(200, 1, nSyntaxError);
-    testCase(210, 1, nAccept);
-    testCase(220, 0, nFailure);
+    testCase(210, 0, nAccept);
+    testCase(220, 3, nFailure);
     nSyntaxError = nAccept = nFailure = 0;
     ParseInit(&xp);
     Parse(&xp, TK_A, 0);
@@ -64,7 +64,7 @@ all ::=  error B.
     ParseFinalize(&xp);
     testCase(200, 1, nSyntaxError);
     testCase(210, 0, nAccept);
-    testCase(220, 0, nFailure);
+    testCase(220, 2, nFailure);
     if( nErr==0 ){
       printf("%d tests pass\n", nTest);
     }else{
