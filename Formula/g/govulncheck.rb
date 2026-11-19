class Govulncheck < Formula
  desc "Database client and tools for the Go vulnerability database"
  homepage "https://github.com/golang/vuln"
  # git checkout needed for buildInfo support
  url "https://github.com/golang/vuln.git",
      tag:      "v1.10.0",
      revision: "ef4cb2f7cae47fe3e21fc596455f694951867b29"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/golang/vuln.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3460e4927b230b024859badf849740c58cd70b2099c4b49d4efa982739d2c53c"
  end

  depends_on "go" => [:build, :test]

  # `test do` block queries the Go vulnerability database
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/govulncheck"
  end

  test do
    assert_match "Scanner: govulncheck@v#{version}", shell_output("#{bin}/govulncheck --version")
    mkdir "brewtest" do
      system "go", "mod", "init", "brewtest"
      (testpath/"brewtest/main.go").write <<~GO
        package main

        func main() {}
      GO

      output = shell_output("#{bin}/govulncheck ./...")
      assert_match "No vulnerabilities found.", output
    end
  end
end
