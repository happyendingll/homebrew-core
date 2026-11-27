class Argo < Formula
  desc "Get stuff done with container-native workflows for Kubernetes"
  homepage "https://argoproj.io"
  url "https://github.com/argoproj/argo-workflows.git",
      tag:      "v4.1.7",
      revision: "21748f1a8b8df09c8f8b1d8d3c8d701d93991f29"
  license "Apache-2.0"
  head "https://github.com/argoproj/argo-workflows.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "7800910e3c1a81f19032af5256140c70d506a9db09c0d515590812fe9649d5ff"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "yarn" => :build

  deny_network_access!

  def fetch
    # Run targets that need network access to fetch Go modules
    ENV["GOPATH"] = buildpath/"go"
    system "make", "#{buildpath}/go/bin/openapi-gen",
                   "vendor/modules.txt",
                   "pkg/apis/workflow/v1alpha1/zz_generated.deepcopy.go"
    system "yarn", "install", "--cwd=ui", "--immutable"
  end

  def install
    ENV["GOPATH"] = buildpath/"go"
    system "make", "dist/argo"
    bin.install "dist/argo"

    generate_completions_from_executable(bin/"argo", "completion")
  end

  test do
    assert_match "argo: v#{version}", shell_output("#{bin}/argo version")

    # argo consumes the Kubernetes configuration with the `--kubeconfig` flag
    # Since it is an empty file we expect it to be invalid
    touch testpath/"kubeconfig"
    assert_match "invalid configuration",
      shell_output("#{bin}/argo lint --kubeconfig ./kubeconfig ./kubeconfig 2>&1", 1)
  end
end
