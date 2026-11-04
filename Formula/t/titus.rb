class Titus < Formula
  desc "High-performance secrets scanner"
  homepage "https://github.com/praetorian-inc/titus"
  url "https://github.com/praetorian-inc/titus/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "00b22bc9896f36351259153989ef1a5d1061598e56dfb009097e5a5115742fd5"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "28aea5ca3269fb05cb419879711b86905f6a82ec652d45b65d234a467a7a19cb"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build
  depends_on "vectorscan"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", tags: "vectorscan"), "./cmd/titus"
    generate_completions_from_executable(bin/"titus", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/titus version")

    output = shell_output("#{bin}/titus scan https://github.com/homebrew/.github 2>stderr")
    assert_match "0 new matches\n\nNo findings.", output
    assert_match %r{[1-9]\d*/[1-9]\d* rules compiled for Hyperscan}, File.read("stderr")

    require "utils/linkage"
    libhs = formula_opt_lib("vectorscan")/shared_library("libhs")
    assert Utils.binary_linked_to_library?(bin/"titus", libhs), "No linkage with vectorscan!"
  end
end
