class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.55.0.tar.gz"
  sha256 "e4a651d856021223b7b01adde8b2075a35b28767407ffedc332ad1f515e36200"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b710b76057a44a653c570970b5126476971c3e0924fb7cf99f7268626f14ab47"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8cd04309baaf190de39e6dec9e0c5fd2b7e578a972d5cb5ac09e6f56255d3c5e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0b82e749bd37e1ac5d6219888a603049a62559940e784a3ad34b8f702200ee14"
    sha256 cellar: :any,                 arm64_linux:       "0240fd768774b45bd1a0eec4b4df763da9b94a9f6f2e4e57c85dcd579bf2b512"
    sha256 cellar: :any,                 x86_64_linux:      "67dff1253a2ac4c4bb1fb8433d5a539ab19e5d64c432e7733bcf0e749fa3c107"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"railway", "completion")
  end

  test do
    output = shell_output("#{bin}/railway init 2>&1", 1).chomp
    assert_match "Unauthorized. Please login with `railway login`", output

    assert_equal "railway #{version}", shell_output("#{bin}/railway --version").strip
  end
end
