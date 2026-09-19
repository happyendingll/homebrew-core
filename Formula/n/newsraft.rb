class Newsraft < Formula
  desc "Terminal feed reader"
  homepage "https://codeberg.org/newsraft/newsraft"
  url "https://codeberg.org/newsraft/newsraft/archive/newsraft-0.37.tar.gz"
  sha256 "725fdbf4c14d87eb7e926aebd9b116f540dca812bea02e73078070156d986ad4"
  license "ISC"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "7ac40bde0ad3e657c1b5d774527999d7fca2218c75f67b930e401dff73fd2bfd"
  end

  depends_on "scdoc" => :build
  depends_on "gumbo-parser"

  uses_from_macos "curl"
  uses_from_macos "expat"
  uses_from_macos "sqlite"

  def install
    # On macOS `_XOPEN_SOURCE` masks cfmakeraw() / SIGWINCH; override FEATURECFLAGS.
    featureflags = "-D_DEFAULT_SOURCE -D_BSD_SOURCE"
    featureflags << " -D_DARWIN_C_SOURCE" if OS.mac?

    system "make", "FEATURECFLAGS=#{featureflags}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    ENV["LC_ALL"] = "en_US.UTF-8"

    assert_match version.to_s, shell_output("#{bin}/newsraft -v 2>&1")

    system "#{bin}/newsraft -l test 2>&1 || :"
    assert_match "[INFO] Okay... Here we go", File.read("test")
  end
end
