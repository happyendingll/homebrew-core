class Mdp < Formula
  desc "Command-line based markdown presentation tool"
  homepage "https://github.com/visit1985/mdp"
  url "https://github.com/visit1985/mdp/archive/refs/tags/1.0.19.tar.gz"
  sha256 "4043838ff3048a5234ea6e24ab42301ab78ff3f51ed6ba19c0c4711414f6a74a"
  license "GPL-3.0-or-later"
  head "https://github.com/visit1985/mdp.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e37a4ec5d8095fbb22ff82065aad94016892f37f7fbe681c75495217fb1cb0e3"
  end

  uses_from_macos "ncurses"

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
    pkgshare.install "sample.md"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mdp -v")
  end
end
