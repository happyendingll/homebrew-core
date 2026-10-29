class KubernetesCli < Formula
  desc "Kubernetes command-line interface"
  homepage "https://kubernetes.io/docs/reference/kubectl/"
  url "https://github.com/kubernetes/kubernetes.git",
      tag:      "v1.37.2",
      revision: "c50e5395f1ae2d4a2c05f28fdcc38c0916cc1a32"
  license "Apache-2.0"
  head "https://github.com/kubernetes/kubernetes.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "f2f1caffc8366f28447a6273663f59bec74bb5527966a0d9747d220c75bf3e8c"
  end

  # TODO: unpin go@1.26 when Go 1.27's ML-DSA ClientHello no longer gets reset by TLS middleboxes
  # Upstream also builds v1.37 with Go 1.26
  # ref: https://github.com/golang/go/issues/81199
  depends_on "go@1.26" => :build

  on_macos do
    depends_on "bash" => :build
    depends_on "coreutils" => :build
  end

  # Go dependencies are vendored
  deny_network_access!

  def install
    ENV.prepend_path "PATH", formula_opt_libexec("coreutils")/"gnubin" if OS.mac? # needs GNU date
    ENV["FORCE_HOST_GO"] = "1"
    system "make", "WHAT=cmd/kubectl"
    bin.install "_output/bin/kubectl"

    generate_completions_from_executable(bin/"kubectl", shell_parameter_format: :cobra)

    # Install man pages
    # Leave this step for the end as this dirties the git tree
    system "hack/update-generated-docs.sh"
    man1.install Dir["docs/man/man1/*.1"]
  end

  test do
    run_output = shell_output("#{bin}/kubectl 2>&1")
    assert_match "kubectl controls the Kubernetes cluster manager.", run_output

    version_output = shell_output("#{bin}/kubectl version --client --output=yaml 2>&1")
    assert_match "gitTreeState: clean", version_output
    assert_match stable.specs[:revision].to_s, version_output
  end
end
