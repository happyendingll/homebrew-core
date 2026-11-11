class Kops < Formula
  desc "Production Grade K8s Installation, Upgrades, and Management"
  homepage "https://kops.sigs.k8s.io/"
  url "https://github.com/kubernetes/kops/archive/refs/tags/v1.37.0.tar.gz"
  sha256 "3e393baa5e8461429cca56118f4dd2c371735d7750429bf7792d4e83bb8feb93"
  license "Apache-2.0"
  head "https://github.com/kubernetes/kops.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3aaeaa1a4a5142fa28d51cbba2dc017720b9202cb5674f698daf034c7843c068"
  end

  depends_on "go" => :build
  depends_on "kubernetes-cli"

  deny_network_access!

  def install
    ldflags = "-X k8s.io/kops.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "k8s.io/kops/cmd/kops"

    generate_completions_from_executable(bin/"kops", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kops version")
    assert_match "no context set in kubecfg", shell_output("#{bin}/kops validate cluster 2>&1", 1)
  end
end
