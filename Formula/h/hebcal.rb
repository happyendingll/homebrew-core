class Hebcal < Formula
  desc "Perpetual Jewish calendar for the command-line"
  homepage "https://hebcal.github.io/"
  url "https://github.com/hebcal/hebcal/archive/refs/tags/v5.18.0.tar.gz"
  sha256 "0a7eb7b9922f5b42bd6776a3eb32bbf645458009c26a787c20011b96f6c33636"
  license "GPL-2.0-or-later"
  head "https://github.com/hebcal/hebcal.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "5674b3a62ca2721431ea68632ebfc3ab51a82e8d56f4256638ec21f49dd1f2f3"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    # populate DEFAULT_CITY variable
    system "make", "dcity.go", "man"
    system "go", "build", *std_go_args
    man1.install "hebcal.1"
  end

  test do
    output = shell_output("#{bin}/hebcal 01 01 2020").chomp
    assert_equal output, "1/1/2020 4th of Tevet, 5780"
  end
end
