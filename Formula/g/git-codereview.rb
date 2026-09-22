class GitCodereview < Formula
  desc "Tool for working with Gerrit code reviews"
  homepage "https://pkg.go.dev/golang.org/x/review/git-codereview"
  url "https://github.com/golang/review/archive/refs/tags/v1.21.0.tar.gz"
  sha256 "d1215854ba15b8f7d457bb00637f8f137f775004e5a6568dab82d27755dbd587"
  license "BSD-3-Clause"
  head "https://github.com/golang/review.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "967c7ed429d6357255e5755405f21380a68eff60bdc4355dee7e8c8521ef6152"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    system "go", "build", *std_go_args, "./git-codereview"
  end

  test do
    system "git", "init"
    system "git", "codereview", "hooks"
    assert_match "git-codereview hook-invoke", (testpath/".git/hooks/commit-msg").read
  end
end
