class Malbolge < Formula
  desc "Deliberately difficult to program esoteric programming language"
  homepage "https://esoteric.sange.fi/orphaned/malbolge/README.txt"
  url "https://esoteric.sange.fi/orphaned/malbolge/malbolge.c"
  version "0.1.0"
  sha256 "ca3b4f321bc3273195eb29eee7ee2002031b057c2bf0c8d7a4f7b6e5b3f648c0"
  license :public_domain

  livecheck do
    skip "No longer developed or maintained"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "47a1fc38f09b7e72196896e880243789fa1ac73705a728fc3955bb99f653799f"
  end

  patch :DATA

  deny_network_access!

  def install
    system ENV.cxx, "malbolge.c", "-o", "malbolge"
    bin.install "malbolge"
  end

  test do
    (testpath/"hello.mb").write <<~EOS
      (=<`#9]~6ZY32Vx/4Rs+0No-&Jk)"Fh}|Bcy?`=*z]Kw%oG4UUS0/@-ejc(:'8dc
    EOS
    assert_equal "Hello World!", shell_output("#{bin}/malbolge hello.mb")

    (testpath/"bad.mb").write "aaaa\n"
    assert_match "invalid character in source file", shell_output("#{bin}/malbolge bad.mb 2>&1", 1)
  end
end

__END__
--- /malbolge.c
+++ /malbolge.c
25d24
< #include <malloc.h>
