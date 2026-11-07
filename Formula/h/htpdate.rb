class Htpdate < Formula
  desc "Synchronize time with remote web servers"
  homepage "https://www.vervest.org/htp/"
  url "https://github.com/twekkel/htpdate/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "92a787338666d02d5b871444de5b0d5128f789d041342204f9c9837309da8080"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ea36a8b75e95273bbcb3d7000d16ab177377e9698fcfeed157e8b875831074ce"
  end

  def install
    system "make", "prefix=#{prefix}",
                   "STRIP=/usr/bin/strip",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "install"
  end

  test do
    system sbin/"htpdate", "-q", "-d", "-u", ENV["USER"], "example.org"
  end
end
