class LdFindCodeRefs < Formula
  desc "Build tool for sending feature flag code references to LaunchDarkly"
  homepage "https://launchdarkly.com"
  url "https://github.com/launchdarkly/ld-find-code-refs/archive/refs/tags/v2.18.4.tar.gz"
  sha256 "0f0da15bd8785de0a75a5876660ddcd12ac21deba176bd40760d65cb2e01af94"
  license "Apache-2.0"
  head "https://github.com/launchdarkly/ld-find-code-refs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "e9b088458eba9efa31b7289285eaaba52e3d83154f2df1c181c4878cebd60c00"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/ld-find-code-refs"

    generate_completions_from_executable(bin/"ld-find-code-refs", shell_parameter_format: :cobra)
  end

  test do
    system "git", "init"
    (testpath/"README").write "Testing"
    (testpath/".gitignore").write "Library"
    system "git", "add", "README", ".gitignore"
    system "git", "commit", "-m", "Initial commit"

    assert_match "could not retrieve flag key",
      shell_output("#{bin}/ld-find-code-refs --dryRun \
                   --ignoreServiceErrors -t=xx -p=test -r=test -d=. 2>&1", 1)
  end
end
