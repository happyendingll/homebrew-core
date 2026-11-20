class Fluxcd < Formula
  desc "Open and extensible continuous delivery solution for Kubernetes"
  homepage "https://fluxcd.io"
  url "https://github.com/fluxcd/flux2/archive/refs/tags/v2.10.1.tar.gz"
  sha256 "c51e8faaaa57ecb517a8956800973ea39fd30b7a003a6eb3d25f88595ae1a093"
  license "Apache-2.0"
  head "https://github.com/fluxcd/flux2.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "1b8a7ecbce59c72a1672b33b154609632d4661c7f68c90a22fe4ea75adf8db11"
  end

  depends_on "go" => :build
  depends_on "kustomize" => :build

  conflicts_with "fantom", because: "both install `flux` binaries"
  conflicts_with "flux", because: "both install `flux` binaries"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
    system "make", "cmd/flux/.manifests.done"
  end

  def install
    system "make", "build", "VERSION=#{version}"
    bin.install "bin/flux"
    generate_completions_from_executable(bin/"flux", "completion")
  end

  test do
    assert_match "connection refused",
      shell_output("#{bin}/flux reconcile source git test 2>&1", 1)
  end
end
