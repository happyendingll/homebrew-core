class Hz < Formula
  desc "Golang HTTP framework for microservices"
  homepage "https://www.cloudwego.io"
  url "https://github.com/cloudwego/hertz/archive/refs/tags/cmd/hz/v0.9.8.tar.gz"
  sha256 "1afe64cad65a12cb717521427371ce092fbefaf4c180669e8248f1926f71ec9f"
  license "Apache-2.0"
  head "https://github.com/cloudwego/hertz.git", branch: "main"

  livecheck do
    url :stable
    regex(%r{^cmd/hz/v?(\d+(?:\.\d+)+)$}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "af7a3a85a807bb0a4916646d360817134276579c90c558945698bb4ba3c19967"
  end

  depends_on "go" => [:build, :test]

  deny_network_access!

  def fetch
    system "go", "mod", "download", "-C", "cmd/hz"
  end

  def install
    cd "cmd/hz" do
      system "go", "build", *std_go_args
    end
    bin.install_symlink bin/"hz" => "thrift-gen-hertz"
    bin.install_symlink bin/"hz" => "protoc-gen-hertz"
  end

  test do
    ENV["GOPATH"] = testpath

    output = shell_output("#{bin}/hz --version 2>&1")
    assert_match "hz version v#{version}", output

    system bin/"hz", "new", "--mod=test"
    assert_path_exists testpath/"main.go"
    refute_predicate (testpath/"main.go").size, :zero?
  end
end
