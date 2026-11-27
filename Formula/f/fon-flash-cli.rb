class FonFlashCli < Formula
  desc "Flash La Fonera and Atheros chipset compatible devices"
  homepage "https://www.gargoyle-router.com/wiki/doku.php?id=fon_flash"
  url "https://github.com/ericpaulbishop/gargoyle/archive/refs/tags/v1.15.0.tar.gz"
  sha256 "6d1b64d1ce2876b89dd70d4dae992bda76a37664d228459c0525076039aa6a16"
  license "GPL-2.0-or-later"
  head "https://github.com/ericpaulbishop/gargoyle.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "97e5405a82daa6f86df485c1155b7c7c42b69cf7546615437c19ab5205e539f8"
  end

  uses_from_macos "libpcap"

  def install
    cd "fon-flash" do
      system "make", "fon-flash"
      bin.install "fon-flash"
    end
  end

  test do
    system bin/"fon-flash"
  end
end
