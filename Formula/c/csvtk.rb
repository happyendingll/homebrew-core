class Csvtk < Formula
  desc "Cross-platform, efficient and practical CSV/TSV toolkit in Golang"
  homepage "https://bioinf.shenwei.me/csvtk"
  url "https://github.com/shenwei356/csvtk/archive/refs/tags/v0.39.0.tar.gz"
  sha256 "4c6cdae73e9ef357f2b511a9ff0c055d7abe6140afaf67e668008558425b1723"
  license "MIT"
  head "https://github.com/shenwei356/csvtk.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "1d73588f3a3363c17dc31437bcdb26e64737d09a81c2b8db37622d08b7fb7810"
  end

  depends_on "go" => :build

  resource "homebrew-testdata", :test do
    url "https://raw.githubusercontent.com/shenwei356/csvtk/e7b72224a70b7d40a8a80482be6405cb7121fb12/testdata/1.csv"
    sha256 "3270b0b14178ef5a75be3f2e3fdcf93152e3949f9f8abb3382cb00755b62505b"
  end

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./csvtk"

    # We do this because the command to generate completions doesn't print them
    # to stdout and only writes them to a file
    system bin/"csvtk", "genautocomplete", "--shell", "bash", "--file", "csvtk.bash"
    system bin/"csvtk", "genautocomplete", "--shell", "zsh", "--file", "_csvtk"
    system bin/"csvtk", "genautocomplete", "--shell", "fish", "--file", "csvtk.fish"
    bash_completion.install "csvtk.bash" => "csvtk"
    zsh_completion.install "_csvtk"
    fish_completion.install "csvtk.fish"
  end

  test do
    resource("homebrew-testdata").stage do
      assert_equal "3,bar,handsome\n",
      shell_output("#{bin}/csvtk grep -H -N -n -f 2 -p handsome 1.csv")
    end
  end
end
