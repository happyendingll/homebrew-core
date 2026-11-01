class Wails < Formula
  desc "Create beautiful applications using Go"
  homepage "https://wails.io"
  url "https://github.com/wailsapp/wails/archive/refs/tags/v3.1.0.tar.gz"
  sha256 "d98866b5f7a2e2378a3cc5ca76422bcef27d669bbe1dd5792a35db2589262e1f"
  license "MIT"
  head "https://github.com/wailsapp/wails.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(:?\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "3041c2a2ed917e2ac8549aecfb751037b3f265b289d705be274feff9d241dbab"
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
