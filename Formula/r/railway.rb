class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.57.11.tar.gz"
  sha256 "17f4de01696685865bb470720485fa92d0926230eb8a3dc123dae56b94a6de7e"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5ec73c239a271baf6347f46a4aaac74d79c7b1101603b345ec34cf8ec47d3eb1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ba2a439a2a75f7ecbf4b8c7637b75b1d581d6d9d6487f0a1d22142d3060f18fd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "61d49c384058aaa6f7b9d1d22de13c197211c0980e3957f8c7420ea4de26b0ee"
    sha256 cellar: :any,                 arm64_linux:       "63302f4e769aec5f27295315798f3195c667fb8148103367a345aca712cd3459"
    sha256 cellar: :any,                 x86_64_linux:      "534f5fc993576db1d346ff662e09845f9eea864593f11e019b5de8407fa9086f"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

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
