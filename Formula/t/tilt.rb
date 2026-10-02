class Tilt < Formula
  desc "Define your dev environment as code. For microservice apps on Kubernetes"
  homepage "https://tilt.dev/"
  url "https://github.com/tilt-dev/tilt.git",
      tag:      "v0.37.8",
      revision: "9f48972fd201a27565380c093f2bac8001a7b130"
  license "Apache-2.0"
  head "https://github.com/tilt-dev/tilt.git", branch: "master"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2e7938286aa6f3aa615fca23f44df3b9c3cfbc87978eefdd606647ddaed1ad34"
  end

  depends_on "corepack" => :build # for newer yarn
  depends_on "go" => :build
  depends_on "node" => :build

  deny_network_access!

  def fetch
    ENV["COREPACK_ENABLE_DOWNLOAD_PROMPT"] = "0"

    # Go dependencies are vendored, so only the frontend assets need
    # downloading; bundling them downloads yarn and npm packages.
    system "make", "build-js"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    ldflags = %W[
      -X main.version=#{version}
      -X main.commit=#{Utils.git_head}
      -X main.date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/tilt"

    generate_completions_from_executable(bin/"tilt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tilt version")

    assert_match "Error: No tilt apiserver found: tilt-default", shell_output("#{bin}/tilt api-resources 2>&1", 1)
  end
end
