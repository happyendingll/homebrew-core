class Monolith < Formula
  desc "CLI tool for saving complete web pages as a single HTML file"
  homepage "https://github.com/Y2Z/monolith"
  url "https://github.com/Y2Z/monolith/archive/refs/tags/v2.11.6.tar.gz"
  sha256 "19390d1032cd2e10a7a589228fd035ab60b07f093a46e8a2bce4fa1c08f5e66b"
  license "CC0-1.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "134364720e5f27b9875ed6793ba01ce94d92c0109eff9dd6e9a98850574fbeb6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"monolith", "https://lyrics.github.io/db/P/Portishead/Dummy/Roads/"
  end
end
