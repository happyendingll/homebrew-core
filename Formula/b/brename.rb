class Brename < Formula
  desc "Cross-platform command-line tool for safe batch renaming via regular expressions"
  homepage "https://github.com/shenwei356/brename"
  url "https://github.com/shenwei356/brename/archive/refs/tags/v2.15.0.tar.gz"
  sha256 "ad957eea95c7b1f8283a08c46f7128e0f944d29e139bf63557da17f1906b47df"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c9d6be33a261f48af72bdff8eac46e96baea28166052215631f6597a6eb037c2"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(tags: "netgo")
  end

  test do
    (1..9).each do |n|
      (testpath/"Homebrew-#{n}.txt").write n.to_s
    end

    system bin/"brename", "-p", "Homebrew-(\\d+).txt", "-r", "$1.txt", "-v", "0"

    (1..9).each do |n|
      assert_equal n.to_s, (testpath/"#{n}.txt").read
      refute_path_exists testpath/"Homebrew-#{n}.txt"
    end
  end
end
