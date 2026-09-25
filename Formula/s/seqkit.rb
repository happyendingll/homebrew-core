class Seqkit < Formula
  desc "Cross-platform and ultrafast toolkit for FASTA/Q file manipulation in Golang"
  homepage "https://bioinf.shenwei.me/seqkit"
  url "https://github.com/shenwei356/seqkit/archive/refs/tags/v2.14.0.tar.gz"
  sha256 "7df95904ce438c1a1a7b1fc06f20479a169e69209ac59abae8e80c60a1e65d60"
  license "MIT"
  head "https://github.com/shenwei356/seqkit.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "4827b87e1b50635dfc9af59a15cbb86f2eb59098b05f75f35b96ecf759f9b24a"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./seqkit"

    # generate_completions_from_executable(bin/"seqkit", "genautocomplete", "--shell")
    # We do this because the command to generate completions doesn't print them
    # to stdout and only writes them to a file
    system bin/"seqkit", "genautocomplete", "--shell", "bash", "--file", "seqkit.bash"
    system bin/"seqkit", "genautocomplete", "--shell", "zsh", "--file", "_seqkit"
    system bin/"seqkit", "genautocomplete", "--shell", "fish", "--file", "seqkit.fish"
    bash_completion.install "seqkit.bash" => "seqkit"
    zsh_completion.install "_seqkit"
    fish_completion.install "seqkit.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/seqkit version")

    resource "homebrew-testdata" do
      url "https://raw.githubusercontent.com/shenwei356/seqkit/e37d70a7e0ca0e53d6dbd576bd70decac32aba64/tests/seqs4amplicon.fa"
      sha256 "b0f09da63e3c677cc698d5cdff60e2d246368263c22385937169a9a4c321178a"
    end

    resource("homebrew-testdata").stage do
      assert_equal ">seq1\nCCCACTGAAA",
      shell_output("#{bin}/seqkit amplicon --quiet -F CCC -R TTT seqs4amplicon.fa").strip
    end
  end
end
