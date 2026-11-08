class Baml < Formula
  desc "Programming language for agents"
  homepage "https://boundaryml.com/"
  url "https://github.com/BoundaryML/baml/archive/refs/tags/baml-wrapper-0.3.1.tar.gz"
  sha256 "9948cd57ed830b200a955119b31fe48753464e7e0d2050105056705d425f74ab"
  license "Apache-2.0"
  head "https://github.com/BoundaryML/baml.git", branch: "canary"

  livecheck do
    url :stable
    regex(/^baml-wrapper[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "b3c8838ee91d039a7b5c550492ecf1b6acd2fad815906d5f3c471f01373f6056"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  allow_network_access! :test

  def fetch
    cd "baml_language/crates" do
      system "cargo", "fetch", *std_cargo_fetch_args
    end
  end

  def install
    system "cargo", "install", *std_cargo_args(
      path:     "baml_language/crates/baml",
      features: "no-self-update",
    )
  end

  test do
    ENV["BAML_HOME"] = testpath/"baml-home"
    ENV.delete "BAML_VERSION"

    system bin/"baml", "toolchain", "use", "--global", "canary"
    shell_output("#{bin}/baml run -e 'baml.sys.exit(42)'", 42)
    assert_match "self-update is disabled in this build",
                 shell_output("#{bin}/baml self-update 2>&1", 1)
  end
end
