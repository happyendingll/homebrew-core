class Gnmic < Formula
  desc "GNMI CLI client and collector"
  homepage "https://gnmic.openconfig.net"
  url "https://github.com/openconfig/gnmic/archive/refs/tags/v0.49.1.tar.gz"
  sha256 "4f3ad40acb2fc4643eecbd4f0feb3b979f9b1139ff492aeb90dc02c309012c5c"
  license "Apache-2.0"
  head "https://github.com/openconfig/gnmic.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "07804509fb457d812821619ef6e2a346ef4f666ed496418aaa1b26cfd0def600"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/openconfig/gnmic/pkg/version.Version=#{version}
      -X github.com/openconfig/gnmic/pkg/version.Commit=#{tap.user}
      -X github.com/openconfig/gnmic/pkg/version.Date=#{time.iso8601}
      -X github.com/openconfig/gnmic/pkg/version.GitURL=https://github.com/openconfig/gnmic
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"gnmic", "completion")
  end

  test do
    connection_output = shell_output("#{bin}/gnmic -u gnmi -p dummy --skip-verify \
                                     --timeout 1s -a 127.0.0.1:0 capabilities 2>&1", 1)
    assert_match "target \"127.0.0.1:0\", capabilities request failed", connection_output

    assert_match version.to_s, shell_output("#{bin}/gnmic version")
  end
end
