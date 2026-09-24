class Kpt < Formula
  desc "Toolchain for composing, customizing, and deploying Kubernetes packages"
  homepage "https://kpt.dev"
  url "https://github.com/kptdev/kpt/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "334bfa273fd57af06324f30e7447306c93b03d7146ddbc2aae8b63dd52b6fc4e"
  license "Apache-2.0"
  head "https://github.com/kptdev/kpt.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "30d606b9369ded37bd2e37d3e6db888b756d9da2cf784676c0a8868683eeabce"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/kptdev/kpt/run.version=#{version}"
    system "go", "build", *std_go_args(ldflags:)
    generate_completions_from_executable(bin/"kpt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kpt version")

    (testpath/"pkg/Kptfile").write <<~YAML
      apiVersion: kpt.dev/v1
      kind: Kptfile
      metadata:
        name: example
    YAML
    (testpath/"pkg/deployment.yaml").write <<~YAML
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: nginx
    YAML
    output = shell_output("#{bin}/kpt pkg tree #{testpath}/pkg")
    assert_match "Kptfile example", output
    assert_match "Deployment nginx", output
  end
end
