class FlowCli < Formula
  desc "Command-line interface that provides utilities for building Flow applications"
  homepage "https://onflow.org"
  url "https://github.com/onflow/flow-cli/archive/refs/tags/v2.19.0.tar.gz"
  sha256 "6dc750c4ff4230b66220d136309b6820af17d45468c28f3adc14f9eefc536583"
  license "Apache-2.0"
  head "https://github.com/onflow/flow-cli.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f2290862d71d1af93537f80e2568bb36a649374cf9b872650907020f6f881fa4"
  end

  depends_on "go@1.26" => :build

  conflicts_with "flow", "flow-control", because: "both install `flow` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "cmd/flow/flow", "VERSION=v#{version}"
    bin.install "cmd/flow/flow"

    generate_completions_from_executable(bin/"flow", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/flow version")

    (testpath/"hello.cdc").write <<~CDC
      access(all) fun main() {
        log("Hello, world!")
      }
    CDC

    system bin/"flow", "cadence", "hello.cdc"
  end
end
