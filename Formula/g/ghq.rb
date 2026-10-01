class Ghq < Formula
  desc "Remote repository management made easy"
  homepage "https://github.com/x-motemen/ghq"
  url "https://github.com/x-motemen/ghq.git",
      tag:      "v1.11.2",
      revision: "b9273dd116d09b423073b83e7c0d82ef508d985a"
  license "MIT"
  head "https://github.com/x-motemen/ghq.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "b88f51bc84884abad920627e2b8a61c68fbab4b77806abc83e3ce012046f99a3"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download", "all"
  end

  def install
    system "make", "build", "VERBOSE=1"
    bin.install "ghq"
    bash_completion.install "misc/bash/_ghq" => "ghq"
    zsh_completion.install "misc/zsh/_ghq"
    fish_completion.install "misc/fish/ghq.fish"
  end

  test do
    assert_match "#{testpath}/ghq", shell_output("#{bin}/ghq root")
  end
end
