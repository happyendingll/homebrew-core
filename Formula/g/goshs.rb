class Goshs < Formula
  desc "Simple, yet feature-rich web server written in Go"
  homepage "https://goshs.de"
  url "https://github.com/goshs-labs/goshs/archive/refs/tags/v2.1.8.tar.gz"
  sha256 "3d1e4ab15d7b6f5fba7d1e793fbb803dc085f6cc66d3c39d9f8a818ae4d55346"
  license "MIT"
  head "https://github.com/goshs-labs/goshs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "b62135d1d88af2d6dbacfe0f23be40186c883ec33dd875628a1a8e9432fe4d92"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goshs -v")

    (testpath/"test.txt").write "Hello, Goshs!"

    port = free_port
    with_test_process(bin/"goshs", "-p", port.to_s, "-d", testpath, "-si") do
      output = shell_output("curl --retry 5 --retry-connrefused -s http://localhost:#{port}/test.txt")
      assert_match "Hello, Goshs!", output
    end
  end
end
