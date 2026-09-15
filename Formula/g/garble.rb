class Garble < Formula
  desc "Obfuscate Go builds"
  homepage "https://github.com/burrowers/garble"
  url "https://github.com/burrowers/garble/archive/refs/tags/v0.17.0.tar.gz"
  sha256 "feab001d7e9ff4ce66011ebd70791de93eb1554d34d3ea44c33d102a25c1be0a"
  license "BSD-3-Clause"
  revision 3
  head "https://github.com/burrowers/garble.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "4f09a6430beb9a29aead86f07f9fbb3928361d98bb9efef2ed2b58f51df1d142"
  end

  # TODO: unpin go@1.26 when garble supports go 1.27
  depends_on "go@1.26" => [:build, :test]

  def install
    system "go", "build", *std_go_args
  end

  test do
    (testpath/"hello.go").write <<~GO
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    GO

    # TODO: remove when unpinning go 1.26
    ENV.prepend_path "PATH", formula_opt_libexec("go@1.26")/"bin" # for keg_only go 1.26 binary

    # `garble` breaks our git shim by clearing the environment.
    # Remove once git is no longer needed. See caveats:
    # https://github.com/burrowers/garble?tab=readme-ov-file#caveats
    ENV.remove "PATH", "#{HOMEBREW_SHIMS_PATH}/shared:"

    system bin/"garble", "-literals", "-tiny", "build", testpath/"hello.go"
    assert_equal "Hello World\n", shell_output("#{testpath}/hello")

    expected = <<~EOS
      Build settings:
            -buildmode exe
             -compiler gc
             -trimpath true
    EOS
    assert_match expected, shell_output("#{bin}/garble version")
  end
end
