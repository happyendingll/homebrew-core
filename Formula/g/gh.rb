class Gh < Formula
  desc "GitHub command-line tool"
  homepage "https://cli.github.com/"
  url "https://github.com/cli/cli/archive/refs/tags/v2.105.0.tar.gz"
  sha256 "3a8fddd2ca0f7c96983a251d3971a84ef042b230b26ca696e5e6ed811cd0ed8d"
  license "MIT"
  compatibility_version 1
  head "https://github.com/cli/cli.git", branch: "trunk"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "6ef011c0f7043bbe0251c1e41c0f54999f8efcc90f3ba0f4aa25f014592629cc"
  end

  depends_on "go" => :build

  allow_network_access! :build

  def install
    gh_version = if build.stable?
      version.to_s
    else
      Utils.safe_popen_read("git", "describe", "--tags", "--dirty").chomp
    end

    ldflags = %w[-s -w]
    ENV.prepend_path "PATH", buildpath/"bin"

    with_env(
      "GH_VERSION"   => gh_version,
      "GOBIN"        => buildpath/"bin",
      "GO_LDFLAGS"   => ldflags.join(" "),
      "GO_BUILDTAGS" => "updateable",
    ) do
      system "make", "licenses"
      system "make", "bin/gh", "manpages"
    end
    bin.install "bin/gh"
    man1.install buildpath.glob("share/man/man1/gh*.1")
    generate_completions_from_executable(bin/"gh", "completion", "-s")
  end

  test do
    assert_match "gh version #{version}", shell_output("#{bin}/gh --version")
    assert_match "Work with GitHub issues", shell_output("#{bin}/gh issue 2>&1")
    assert_match "Work with GitHub pull requests", shell_output("#{bin}/gh pr 2>&1")
    assert_match "GitHub CLI third-party dependencies", shell_output("#{bin}/gh licenses")
  end
end
