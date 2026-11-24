class Flagd < Formula
  desc "Feature flag daemon with a Unix philosophy"
  homepage "https://flagd.dev"
  url "https://github.com/open-feature/flagd.git",
      tag:      "flagd/v0.19.0",
      revision: "11037220611eab982261d2348b13147b4450b562"
  license "Apache-2.0"
  head "https://github.com/open-feature/flagd.git", branch: "main"

  # The upstream repository contains tags like `core/v1.2.3`,
  # `flagd-proxy/v1.2.3`, etc. but we're only interested in the `flagd/v1.2.3`
  # tags. Upstream only appears to mark the `core/v1.2.3` releases as "latest"
  # and there isn't usually a notable gap between tag and release, so we check
  # the Git tags.
  livecheck do
    url :stable
    regex(%r{^flagd/v?(\d+(?:[.-]\d+)+)$}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "96154ad102c2adc2448c669c187ecf89857dbfd0d4e921da5cd6bc4e807b8e5c"
  end

  depends_on "go" => :build

  # `test do` block runs a local flagd server with flags from a remote URL
  allow_network_access! :test

  def fetch
    ENV["GOPRIVATE"] = "buf.build/gen/go"
    system "make", "workspace-init"
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=#{version}
      -X main.commit=#{Utils.git_head}
      -X main.date=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:), "./flagd/main.go"
    generate_completions_from_executable(bin/"flagd", shell_parameter_format: :cobra)
  end

  test do
    port = free_port
    json_url = "https://raw.githubusercontent.com/open-feature/flagd/main/config/samples/example_flags.json"
    resolve_boolean_command = <<~BASH
      curl \
      --request POST \
      --data '{"flagKey":"myBoolFlag","context":{}}' \
      --header "Content-Type: application/json" \
      localhost:#{port}/schema.v1.Service/ResolveBoolean
    BASH

    with_test_process(bin/"flagd", "start", "-f", json_url, "-p", port.to_s) do
      sleep 3
      assert_match(/true/, shell_output(resolve_boolean_command))
    end
  end
end
