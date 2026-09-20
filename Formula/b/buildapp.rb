class Buildapp < Formula
  desc "Creates executables with SBCL"
  homepage "https://www.xach.com/lisp/buildapp/"
  url "https://github.com/xach/buildapp/archive/refs/tags/release-1.5.6.tar.gz"
  sha256 "d77fb6c151605da660b909af058206f7fe7d9faf972e2c30876d42cb03d6a3ed"
  license "BSD-2-Clause"
  revision 6
  head "https://github.com/xach/buildapp.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "3fb986e31affe3e16a9673a2e9b323af15a8c03bac5f3f7a838ca5ba1602ded5"
  end

  depends_on "sbcl"
  depends_on "zstd"

  def install
    bin.mkpath
    system "make", "install", "DESTDIR=#{prefix}"

    # Work around patchelf corrupting the SBCL core which is appended to binary
    # TODO: Find a better way to handle this in brew, either automatically or via DSL
    if OS.linux? && build.bottle?
      cp bin/"buildapp", prefix
      Utils::Gzip.compress(prefix/"buildapp")
    end
  end

  post_install_steps do
    install_gzipped_executable "buildapp.gz", "bin/buildapp"
  end

  test do
    code = <<~LISP
      (defun f (a) (declare (ignore a)) (write-line "Hello, homebrew"))
    LISP
    system bin/"buildapp", "--eval", code, "--entry", "f", "--output", "t"
    assert_equal "Hello, homebrew\n", shell_output("./t")
  end
end
