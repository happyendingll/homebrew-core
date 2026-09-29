class Mercury < Formula
  desc "Logic/functional programming language"
  homepage "https://mercurylang.org/"
  url "https://dl.mercurylang.org/release/mercury-srcdist-22.01.9.tar.gz"
  sha256 "582639d89530dd6539c3af01b841f682e6554c3ca5c09be124e789d7ca4b2b58"
  license all_of: ["GPL-2.0-only", "LGPL-2.0-only", "MIT"]

  livecheck do
    url "https://dl.mercurylang.org/"
    regex(/href=.*?mercury-srcdist[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "af6e65d28947cfa695932469834488dcd80d739cbfec58287c002ca2d3388b95"
  end

  depends_on "openjdk"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "libedit"

  def install
    args = %w[--without-readline --with-editline]
    system "./configure", *args, *std_configure_args
    system "make", "install", "PARALLEL=-j#{ENV.make_jobs}"

    # Remove batch files for windows.
    bin.glob("*.bat").map(&:unlink)
  end

  test do
    test_string = "Hello Homebrew\n"
    (testpath/"hello.m").write <<~MERCURY
      :- module hello.
      :- interface.
      :- import_module io.
      :- pred main(io::di, io::uo) is det.
      :- implementation.
      main(IOState_in, IOState_out) :-
          io.write_string("#{test_string}", IOState_in, IOState_out).
    MERCURY

    system bin/"mmc", "-o", "hello_c", "hello"
    assert_equal test_string, shell_output("./hello_c")

    system bin/"mmc", "--grade", "java", "hello"
    assert_equal test_string, shell_output("./hello")
  end
end
