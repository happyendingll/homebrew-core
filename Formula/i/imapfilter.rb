class Imapfilter < Formula
  desc "IMAP message processor/filter"
  homepage "https://github.com/lefcha/imapfilter/"
  url "https://github.com/lefcha/imapfilter/archive/refs/tags/v2.8.6.tar.gz"
  sha256 "380bc0848002aadb074ade86f2fe3f5b62612a378173f2b10043527d31f13aeb"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "0fbd95d881cf71181241d0254bcc749c8ed8927046a7961a3c90c0ee9345c5d4"
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
