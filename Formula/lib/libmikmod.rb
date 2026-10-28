class Libmikmod < Formula
  desc "Portable sound library"
  homepage "https://mikmod.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/mikmod/libmikmod/3.3.16/libmikmod-3.3.16.tar.gz"
  sha256 "7b24e41468b0dfe7fae1104ae6a0d7c52e04a65e1851b268c7074e4d06685a53"
  license "LGPL-2.0-or-later"

  livecheck do
    url :stable
    regex(%r{url=.*?/libmikmod[._-](\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "caf1f8042d51debaf2deb57bb86bb8bd529763d8215ae46b285542da4e9f5b2d"
  end

  def install
    mkdir "macbuild" do
      # macOS has CoreAudio, but ALSA, SAM9407 and ULTRA are not supported
      system "../configure", "--prefix=#{prefix}", "--disable-alsa",
                             "--disable-sam9407", "--disable-ultra"
      system "make", "install"
    end
  end

  test do
    system bin/"libmikmod-config", "--version"
  end
end
