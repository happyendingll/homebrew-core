class Wails < Formula
  desc "Create beautiful applications using Go"
  homepage "https://wails.io"
  url "https://github.com/wailsapp/wails/archive/refs/tags/v2.17.0.tar.gz"
  sha256 "1a11268a482edfa984c8ff40415e7597c914f0ee0141574318b72a8f1f3c3d0c"
  license "MIT"
  head "https://github.com/wailsapp/wails.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c5bb7ad7b3bfb8b26f91ac8a1b01907e197816f7356371492f2511677f148b90"
  end

  depends_on "go"

  # Test scaffolds a project, which downloads Go modules
  allow_network_access! :test

  def fetch
    # Match `install`, which builds the v2 module with workspace mode disabled
    ENV["GOWORK"] = "off"
    cd "v2" do
      system "go", "mod", "download"
    end
  end

  def install
    # The top-level go.work only lists v3, so disable workspace mode to build v2.
    ENV["GOWORK"] = "off"
    cd "v2" do
      system "go", "build", *std_go_args, "./cmd/wails"
    end
  end

  test do
    ENV["NO_COLOR"] = "1"

    output = shell_output("#{bin}/wails init -n brewtest 2>&1")
    assert_match "# Initialising Project 'brewtest'", output
    assert_match "Template          | Vanilla + Vite", output

    assert_path_exists testpath/"brewtest/go.mod"
    assert_equal "brewtest", JSON.parse((testpath/"brewtest/wails.json").read)["name"]

    assert_match version.to_s, shell_output("#{bin}/wails version")
  end
end
