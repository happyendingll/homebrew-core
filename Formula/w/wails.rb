class Wails < Formula
  desc "Create beautiful applications using Go"
  homepage "https://wails.io"
  url "https://github.com/wailsapp/wails/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "cd80ce78e70c2bb2580b8454230f068b2ba936bce3c17b4b12bb0b88dc6d3761"
  license "MIT"
  head "https://github.com/wailsapp/wails.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "21ad917230b66d71faea335c585b7fc3b4c64920051f74ae157c5dc8d80e365c"
  end

  depends_on "go"

  # Test scaffolds a project, which downloads Go modules
  allow_network_access! :test

  def fetch
    cd "v3" do
      system "go", "mod", "download"
    end
  end

  def install
    # Disable modules that require GTK
    ENV["CGO_ENABLED"] = "0" if OS.linux?
    cd "v3" do
      system "go", "build", *std_go_args, "./cmd/wails3"
    end
  end

  test do
    ENV["NO_COLOR"] = "1"

    output = shell_output("#{bin}/wails init -n brewtest 2>&1")
    assert_match(/Name\s+brewtest/, output)
    assert_match(/Framework\s+Vanilla/, output)

    assert_path_exists testpath/"brewtest/go.mod"
    assert_match 'APP_NAME: "brewtest"', (testpath/"brewtest/Taskfile.yml").read

    assert_match version.to_s, shell_output("#{bin}/wails version 2>&1")
  end
end
