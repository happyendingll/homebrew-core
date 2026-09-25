class Imapfilter < Formula
  desc "IMAP message processor/filter"
  homepage "https://github.com/lefcha/imapfilter/"
  url "https://github.com/lefcha/imapfilter/archive/refs/tags/v2.8.5.tar.gz"
  sha256 "81930d83c99a07305554b2fd283422aefb4f069e13cff971377f3f844e601424"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "e99bb200b7411115970ee900e159dbc126f62190398def441fc140750676e86d"
  end

  depends_on "lua"
  depends_on "openssl@4"
  depends_on "pcre2"

  # Apply open PR by Ubuntu maintainer to support OpenSSL 4
  patch do
    url "https://github.com/lefcha/imapfilter/commit/d0e1b29ee5ae0e6e91944fd5c04b943fc810e13c.patch?full_index=1"
    sha256 "b4c52d30ad177546cac2393722184038d974a3b59bdbc14a832c5e3be27f578b"
    type :unofficial
    resolves "https://github.com/lefcha/imapfilter/pull/317"
  end

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
