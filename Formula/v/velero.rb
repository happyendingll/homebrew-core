class Velero < Formula
  desc "Disaster recovery for Kubernetes resources and persistent volumes"
  homepage "https://velero.io/"
  url "https://github.com/velero-io/velero/archive/refs/tags/v1.18.3.tar.gz"
  sha256 "63ce48e63ae9104e241d323d098e49953ec1659ef243518de292bc479846d74b"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9c4815d82da7d73fd56aee8add1ce1b4245629bc2f7008f1ad9823aeb31fa183"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/vmware-tanzu/velero/pkg/buildinfo.Version=v#{version}]
    system "go", "build", *std_go_args(ldflags:), "-installsuffix", "static", "./cmd/velero"

    generate_completions_from_executable(bin/"velero", "completion")
  end

  test do
    output = shell_output("#{bin}/velero 2>&1")
    assert_match "Velero is a tool for managing disaster recovery", output
    assert_match "Version: v#{version}", shell_output("#{bin}/velero version --client-only 2>&1")
    system bin/"velero", "client", "config", "set", "TEST=value"
    assert_match "value", shell_output("#{bin}/velero client config get 2>&1")
  end
end
