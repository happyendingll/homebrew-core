class Xq < Formula
  desc "Command-line XML and HTML beautifier and content extractor"
  homepage "https://github.com/sibprogrammer/xq"
  url "https://github.com/sibprogrammer/xq/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "d57579a6c2009f3bd0f6b6f66f12744eb895575b767e7a02a099003c6bdcda3d"
  license "MIT"
  head "https://github.com/sibprogrammer/xq.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "80a69da85ee607279d1337c51a7abb976ec4951de8f9e71c9fdac5101033eb08"
  end

  depends_on "go" => :build

  conflicts_with "python-yq", because: "both install `xq` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: :goreleaser)
    man1.install "docs/xq.man" => "xq.1"
    generate_completions_from_executable(bin/"xq", shell_parameter_format: :cobra)
  end

  test do
    version_output = shell_output("#{bin}/xq --version 2>&1")
    assert_match "xq version #{version}", version_output

    run_output = pipe_output(bin/"xq", "<root></root>")
    assert_match("<root/>", run_output)
  end
end
