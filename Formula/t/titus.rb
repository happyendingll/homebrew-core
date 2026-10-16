class Titus < Formula
  desc "High-performance secrets scanner"
  homepage "https://github.com/praetorian-inc/titus"
  url "https://github.com/praetorian-inc/titus/archive/refs/tags/v1.2.11.tar.gz"
  sha256 "757f14f8d51a9a6e7d7b76bf26b3a5491925323b3b03d3e7cddaaed2d3815c3c"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "b037bf70eed481fde521dc259fa05324a9059bfe54bb722e116861bf2c1fcf65"
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
    assert_match "0/0 new matches", output
    assert_match %r{[1-9]\d*/[1-9]\d* rules compiled for Hyperscan}, File.read("stderr")

    require "utils/linkage"
    libhs = formula_opt_lib("vectorscan")/shared_library("libhs")
    assert Utils.binary_linked_to_library?(bin/"titus", libhs), "No linkage with vectorscan!"
  end
end
