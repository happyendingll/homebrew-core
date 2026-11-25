class Connect < Formula
  desc "Provides SOCKS and HTTPS proxy support to SSH"
  homepage "https://github.com/gotoh/ssh-connect"
  url "https://github.com/gotoh/ssh-connect/archive/refs/tags/1.107.tar.gz"
  sha256 "b15bd4d63356b789dc18fa608acb1aaebdfb70caf49ebc9760b89a09f651fa07"
  license "GPL-2.0-or-later"
  head "https://github.com/gotoh/ssh-connect.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "134b23dd96a7c2809d869e34ccd269c393c975b1205c334534fe82fa1f562672"
  end

  def install
    system "make"
    bin.install "connect"
  end

  test do
    system bin/"connect"
  end
end
