class Baml < Formula
  desc "Programming language for agents"
  homepage "https://boundaryml.com/"
  url "https://github.com/BoundaryML/baml/archive/refs/tags/baml-wrapper-0.2.5.tar.gz"
  sha256 "f1539402dfeb4cfd6b4b14f4b21e5b290eb6fb23c965f61e0e5757570333f73d"
  license "Apache-2.0"
  head "https://github.com/BoundaryML/baml.git", branch: "canary"

  livecheck do
    url :stable
    regex(/^baml-wrapper[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "66601f5fa5123d7c1e2ca30753b25d8051a2d3ccd849c6f26914883f474c3e60"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(
      path:     "baml_language/crates/baml",
      features: "no-self-update",
    )
  end

  test do
    ENV["BAML_HOME"] = testpath/"baml-home"
    ENV.delete "BAML_VERSION"

    system bin/"baml", "toolchain", "use", "canary"
    shell_output("#{bin}/baml run -e 'baml.sys.exit(42)'", 42)
    assert_match "self-update is disabled in this build",
                 shell_output("#{bin}/baml self-update 2>&1", 1)
  end
end
