class GitBug < Formula
  desc "Distributed, offline-first bug tracker embedded in git, with bridges"
  homepage "https://github.com/git-bug/git-bug"
  url "https://github.com/git-bug/git-bug/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "31ae65e733e31fbf37ecea8f31966fe46cbeb1657a144876c855d5cf09cffb69"
  license "GPL-3.0-or-later"
  head "https://github.com/git-bug/git-bug.git", branch: "trunk"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "fb3cee39c01a4acfe010118300827c51eb6c0fec28afb9218be9e56fcc493389"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["GOBIN"] = bin
    system "go", "generate"
    system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}")

    man1.install Dir["doc/man/*.1"]
    doc.install Dir["doc/md/*.md"]

    bash_completion.install "misc/completion/bash/git-bug"
    zsh_completion.install "misc/completion/zsh/git-bug" => "_git-bug"
    fish_completion.install "misc/completion/fish/git-bug" => "git-bug.fish"
  end

  test do
    # Version
    assert_match version.to_s, shell_output("#{bin}/git-bug version")
    # Version through git
    assert_match version.to_s, shell_output("git bug version")

    mkdir testpath/"git-repo" do
      system "git", "init", "--initial-branch=main"
      system "git", "config", "user.name", "homebrew"
      system "git", "config", "user.email", "a@a.com"
      system "yes 'a b http://www/www' | git bug user new"
      system "git", "bug", "bug", "new", "-t", "Issue 1", "-m", "Issue body"
      system "git", "bug", "bug", "new", "-t", "Issue 2", "-m", "Issue body"
      system "git", "bug", "bug", "new", "-t", "Issue 3", "-m", "Issue body"

      assert_match "Issue 2", shell_output("git bug bug 'Issue 2'")
    end
  end
end
