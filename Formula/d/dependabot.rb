class Dependabot < Formula
  desc "Tool for testing and debugging Dependabot update jobs"
  homepage "https://github.com/dependabot/cli"
  url "https://github.com/dependabot/cli/archive/refs/tags/v1.96.0.tar.gz"
  sha256 "2c8401f1b98e2b42851e7670599e473458af5cd2ffe02c35383c875158c3b6f9"
  license "MIT"
  head "https://github.com/dependabot/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8c243d67aa8b55d2105049255fa8aba1465e98bf240b10bc552321fe29ddcdbd"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/dependabot/cli/cmd/dependabot/internal/cmd.version=#{version}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/dependabot"

    generate_completions_from_executable(bin/"dependabot", shell_parameter_format: :cobra)
  end

  test do
    ENV["DOCKER_HOST"] = "unix://#{testpath}/invalid.sock"
    assert_match("dependabot version #{version}", shell_output("#{bin}/dependabot --version"))
    output = shell_output("#{bin}/dependabot update bundler Homebrew/homebrew 2>&1", 1)
    assert_match("Cannot connect to the Docker daemon", output)
  end
end
