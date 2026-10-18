class LsLint < Formula
  desc "Extremely fast file and directory name linter"
  homepage "https://ls-lint.org/"
  url "https://github.com/loeffel-io/ls-lint/archive/refs/tags/v2.3.2.tar.gz"
  sha256 "018d9291f96e10386ee68ce7e12b830750c98b6939fb1d587a808d8509affcce"
  license "MIT"
  head "https://github.com/loeffel-io/ls-lint.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "1beaab66bc0b2915ae2665af4fe7be21cba383db65ea477041088f9bc919991c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}"), "./cmd/ls_lint"
    pkgshare.install ".ls-lint.yml"
  end

  test do
    (testpath/"Library").mkdir
    touch testpath/"Library/test.py"

    output = shell_output("#{bin}/ls-lint -config #{pkgshare}/.ls-lint.yml -workdir #{testpath} 2>&1", 1)
    assert_match "Library failed for `.dir` rules: snakecase", output

    assert_match version.to_s, shell_output("#{bin}/ls-lint -version")
  end
end
