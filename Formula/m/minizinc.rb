class Minizinc < Formula
  desc "Medium-level constraint modeling language"
  homepage "https://www.minizinc.org/"
  license "MPL-2.0"
  revision 1
  head "https://github.com/MiniZinc/libminizinc.git", branch: "develop"

  stable do
    url "https://github.com/MiniZinc/libminizinc/archive/refs/tags/2.10.1.tar.gz"
    sha256 "089ea94698cea94ed8396be77559b82d828437a808f5e37d10bccc9f1d39dd33"

    # Prerequisite for the C++14 backport.
    patch do
      url "https://github.com/MiniZinc/libminizinc/commit/7eeecc2edc019f554de80be62da9ba58c31b3eca.patch?full_index=1"
      sha256 "51966edea574e3c985ee5b58c45e3d69199e6dafa8257a2865d8fe5c63d16d7e"
      type :backport
    end

    # Build with C++14 for compatibility with Gecode 6.5.
    patch do
      url "https://github.com/MiniZinc/libminizinc/commit/ced572f764dd17973b5b3bcc14af647e8751a42d.patch?full_index=1"
      sha256 "27d20337469464471773b63a468b58f9e7c4e7c6af204e3daca8d8bd2ad58938"
      type :backport
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "67332b1ca85bb65c17b453ea67ab13bc222d7b95f0c942550e7e69ee724ad3fc"
  end

  depends_on "cmake" => :build

  depends_on "cbc"
  depends_on "cgl"
  depends_on "clp"
  depends_on "coinutils"
  depends_on "gecode"
  depends_on "osi"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"satisfy.mzn").write <<~EOS
      array[1..2] of var bool: x;
      constraint x[1] xor x[2];
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/minizinc --solver gecode_presolver satisfy.mzn").strip

    (testpath/"optimise.mzn").write <<~EOS
      array[1..2] of var 1..3: x;
      constraint x[1] < x[2];
      solve maximize sum(x);
    EOS
    assert_match "==========", shell_output("#{bin}/minizinc --solver cbc optimise.mzn").strip
  end
end
