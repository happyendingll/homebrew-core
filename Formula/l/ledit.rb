class Ledit < Formula
  desc "Line editor for interactive commands"
  homepage "https://pauillac.inria.fr/~ddr/ledit/"
  url "https://github.com/chetmurthy/ledit/archive/refs/tags/2.08.tar.gz"
  sha256 "0f10f70bcdde68ce6514d4eedeb0774653322385a642d1ee696438b5594050f1"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url :stable
    regex(/^(?:ledit[._-])?v?(\d+(?:[.-]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("-", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "2349a905536c179b48013034b1063a9b615db04ecf6e17cffd3053bf8477b62e"
  end

  depends_on "ocaml-findlib" => :build
  depends_on "camlp-streams"
  depends_on "camlp5"
  depends_on "ocaml"

  deny_network_access!

  def install
    # Work around for https://github.com/Homebrew/homebrew-test-bot/issues/805
    if ENV["HOMEBREW_GITHUB_ACTIONS"] && !(Formula["ocaml-findlib"].etc/"findlib.conf").exist?
      ENV["OCAMLFIND_CONF"] = formula_opt_libexec("ocaml-findlib")/"findlib.conf"
    end

    # like camlp5, this build fails if the jobs are parallelized
    ENV.deparallelize
    args = %W[BINDIR=#{bin} LIBDIR=#{lib} MANDIR=#{man1}]
    args << "CUSTOM=" if OS.linux? # Work around brew corrupting appended bytecode
    system "make", *args
    system "make", "install", *args
  end

  test do
    history = testpath/"history"
    pipe_output("#{bin}/ledit -x -h #{history} bash", "exit\n", 0)
    assert_path_exists history
    assert_equal "exit\n", history.read
  end
end
