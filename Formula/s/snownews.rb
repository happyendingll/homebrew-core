class Snownews < Formula
  desc "Text mode RSS newsreader"
  homepage "https://sourceforge.net/projects/snownews/"
  url "https://downloads.sourceforge.net/project/snownews/snownews-1.11.tar.gz"
  sha256 "afd4db7c770f461a49e78bc36e97711f3066097b485319227e313ba253902467"
  license "GPL-3.0-only"
  revision 3

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "9cd4de9a380cae84514fc83a05fd98c72e1b945272635df48345925904eb356d"
  end

  depends_on "gettext" => :build
  depends_on "pkgconf" => :build
  depends_on "ncurses"
  depends_on "openssl@4"

  uses_from_macos "curl"
  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    ENV.deparallelize # due to `install: mkdir /usr/local/Cellar/snownews/1.11_2/share: File exists`
    system "make", "install", "CC=#{ENV.cc}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/snownews --help")
  end
end
