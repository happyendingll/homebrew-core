class Ctlptl < Formula
  desc "Making local Kubernetes clusters fun and easy to set up"
  homepage "https://github.com/tilt-dev/ctlptl"
  url "https://github.com/tilt-dev/ctlptl/archive/refs/tags/v0.9.6.tar.gz"
  sha256 "51af2008cf435a808cb297c9564fe94a4207da541871739bde5062a2a8ede933"
  license "Apache-2.0"
  head "https://github.com/tilt-dev/ctlptl.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "b9fe13d9c8f07866ca91cb1d80af63ca3744c1c43c66d2c73b9335476e79719d"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/ctlptl"

    generate_completions_from_executable(bin/"ctlptl", shell_parameter_format: :cobra)
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/ctlptl version")
    assert_empty shell_output("#{bin}/ctlptl get")
    assert_match "not found", shell_output("#{bin}/ctlptl delete cluster nonexistent 2>&1", 1)
  end
end
