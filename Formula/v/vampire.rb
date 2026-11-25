class Vampire < Formula
  desc "High-performance theorem prover"
  homepage "https://vprover.github.io/"
  url "https://github.com/vprover/vampire/releases/download/v5.1.2/vampire.tar.gz"
  sha256 "b90c97f24af05689b78218788bc8a5438016b340ca725c78b1c5e97aa9f0ec5d"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "66b2cf66e0a95659635b409f9239dd5ee33b7cdbe2589fd648a0757124348ae1"
  end

  depends_on "cmake" => :build

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1600
  end

  fails_with :clang do
    build 1600
    cause "Clang 16.0.0 crashes due to a parser bug"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.smt2").write <<~SMT2
      (set-info :smt-lib-version 2.7)
      (declare-datatype list (par (a) (
        (nil)
        (cons (head a) (tail (list a))))))
      (define-fun-rec sum ((xs (list Real))) Real
        (match xs (
          (nil 0.0)
          ((cons y ys) (+ y (sum ys))))))
      (declare-sort-parameter a)
      (define-fun-rec concat ((xs (list a)) (ys (list a))) (list a)
        (match xs (
          (nil ys)
          ((cons x xs') (cons x (concat xs' ys))))))
      (assert (not (forall ((xs (list Real)) (ys (list Real)))
        (= (sum (concat xs ys)) (+ (sum xs) (sum ys))))))
    SMT2

    system bin/"vampire", "--input_syntax", "smtlib2", "-ind", "struct", "test.smt2"
  end
end
