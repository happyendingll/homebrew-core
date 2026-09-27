class Osdctl < Formula
  desc "CLI tool for managed OpenShift clusters"
  homepage "https://github.com/openshift/osdctl"
  url "https://github.com/openshift/osdctl/archive/refs/tags/v0.65.0.tar.gz"
  sha256 "2e16cab11da13200abb799675fb96efa54f82efc4cea32482d7e6a526bc5472c"
  license "Apache-2.0"
  head "https://github.com/openshift/osdctl.git", branch: "master"

  # TODO: remove if undeprecated
  livecheck do
    url :stable
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "b5d7d63aaa70961e5abada02c56190e7bf4fce62afc51a66cb1ed903bd92ab44"
  end

  # Can be undeprecated on new release or if upstream responds:
  # https://github.com/openshift/osdctl/issues/963
  deprecate! date: "2026-09-18", because: :checksum_mismatch
  disable! date: "2027-09-18", because: :checksum_mismatch

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ENV["GOFLAGS"] = "-mod=readonly"

    ldflags = %W[
      -X github.com/openshift/osdctl/pkg/utils.Version=#{version}
      -X github.com/openshift/osdctl/pkg/utils.InstallMethod=homebrew
    ]

    system "go", "build", *std_go_args(ldflags:)
    generate_completions_from_executable(bin/"osdctl", "--skip-version-check", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/osdctl version")

    assert_match 'Error: required flag(s) "cluster-id" not set',
      shell_output("#{bin}/osdctl --skip-version-check cluster context 2>&1", 1)
  end
end
