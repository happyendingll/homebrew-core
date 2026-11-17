class Imapfilter < Formula
  desc "IMAP message processor/filter"
  homepage "https://github.com/lefcha/imapfilter/"
  url "https://github.com/lefcha/imapfilter/archive/refs/tags/v2.8.7.tar.gz"
  sha256 "fad8eb3779f2b40ba10b1ebaeee57044cac14139a6a59b37d27aeb598f19799d"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "ad09d50472d49e1910b9899b0d871d1577d3185301d206ff3d3ed0aec9cabfdf"
  end

  depends_on "lua"
  depends_on "openssl@4"
  depends_on "pcre2"

  deny_network_access!

  def install
    # find Homebrew's libpcre and lua
    ENV.append "CPPFLAGS", "-I#{formula_opt_include("lua")}/lua"
    ENV.append "LDFLAGS", "-L#{formula_opt_lib("pcre2")}"
    ENV.append "LDFLAGS", "-L#{formula_opt_lib("lua")}"
    ENV.append "LDFLAGS", "-liconv" if OS.mac?
    system "make", "PREFIX=#{prefix}", "MANDIR=#{man}", "MYCFLAGS=#{ENV.cflags}", "MYLDFLAGS=#{ENV.ldflags}"
    system "make", "PREFIX=#{prefix}", "MANDIR=#{man}", "install"

    prefix.install "samples"
  end

  def caveats
    <<~EOS
      You will need to create a ~/.imapfilter/config.lua file.
      Samples can be found in:
        #{prefix}/samples
    EOS
  end

  test do
    system bin/"imapfilter", "-V"
  end
end
