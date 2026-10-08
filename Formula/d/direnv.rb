class Direnv < Formula
  desc "Load/unload environment variables based on $PWD"
  homepage "https://direnv.net/"
  url "https://github.com/direnv/direnv/archive/refs/tags/v2.38.1.tar.gz"
  sha256 "3bd0d49c163204543db8f22f55af8985121db24fe6b21c5b749695e4fbdbb1fe"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "2986e6f1c4ffef535ff0c8f1f8cbfa76d139de49b2b81daae02c5c60fddb747a"
  end

  head do
    url "https://github.com/direnv/direnv.git", branch: "master"

    depends_on "go-md2man" => :build
  end

  depends_on "go" => :build
  depends_on "bash"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    system "make", "install", "PREFIX=#{prefix}", "BASH_PATH=#{formula_opt_bin("bash")}/bash"
  end

  test do
    assert_match "No .envrc or .env found", shell_output("#{bin}/direnv status")

    ENV["TEST"] = "failed"
    (testpath/".envrc").write "export TEST=passed"

    assert_match "No .envrc or .env loaded", shell_output("#{bin}/direnv status")
    system bin/"direnv", "allow"

    assert_match "passed", shell_output("#{bin}/direnv exec . sh -c 'echo $TEST'")
  end
end
