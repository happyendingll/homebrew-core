class Gengetopt < Formula
  desc "Generate C code to parse command-line arguments via getopt_long"
  homepage "https://www.gnu.org/software/gengetopt/"
  url "https://ftpmirror.gnu.org/gengetopt/gengetopt-2.23.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gengetopt/gengetopt-2.23.1.tar.xz"
  sha256 "3b9def48422bd45f78af95936200b7f9287369a3db76c4907c42fe10f4922ab6"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "422c7fcb72d62a2c6d4ee0a3653edffddff048ab4f954b07e4b92ebc0b44623c"
  end

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"

    ENV.deparallelize
    system "make", "install"
  end

  test do
    ggo = <<~EOS
      package "homebrew"
      version "0.9.5"
      purpose "The missing package manager for macOS"

      option "verbose" v "be verbose"
    EOS

    pipe_output("#{bin}/gengetopt --file-name=test", ggo, 0)
    assert_path_exists testpath/"test.h"
    assert_path_exists testpath/"test.c"
    assert_match(/verbose_given/, File.read("test.h"))
  end
end
