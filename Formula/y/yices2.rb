class Yices2 < Formula
  desc "Yices SMT Solver"
  homepage "https://yices.csl.sri.com/"
  url "https://github.com/SRI-CSL/yices2/archive/refs/tags/yices-2.8.0.tar.gz"
  sha256 "cb4c58c3508a5e67c156ba26182cd540af644fb7ba39b2873feebf73f21201b2"
  license "GPL-3.0-or-later"
  compatibility_version 1
  head "https://github.com/SRI-CSL/yices2.git", branch: "master"

  livecheck do
    url :stable
    regex(/^Yices[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "f8d353b29e688ca70165c31db5a809c7008babb81536efafee149f2e071bac35"
  end

  depends_on "autoconf" => :build
  depends_on "gmp"

  uses_from_macos "gperf" => :build

  deny_network_access!

  def install
    system "autoconf"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"lra.smt2").write <<~EOF
      ;; QF_LRA = Quantifier-Free Linear Real Arithmetic
      (set-logic QF_LRA)
      ;; Declare variables x, y
      (declare-fun x () Real)
      (declare-fun y () Real)
      ;; Find solution to (x + y > 0), ((x < 0) || (y < 0))
      (assert (> (+ x y) 0))
      (assert (or (< x 0) (< y 0)))
      ;; Run a satisfiability check
      (check-sat)
      ;; Print the model
      (get-model)
    EOF
    output = shell_output("#{bin}/yices-smt2 #{testpath}/lra.smt2")
    assert_match "sat\n((define-fun x () Real 2.0)\n (define-fun y () Real (- 1.0)))\n", output
  end
end
