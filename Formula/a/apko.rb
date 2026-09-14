class Apko < Formula
  desc "Build OCI images from APK packages directly without Dockerfile"
  homepage "https://github.com/chainguard-dev/apko"
  url "https://github.com/chainguard-dev/apko/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "34c32c9410c6f2a20ae7a60c1607a02414364d9fb23b62bfed353fd2f6c07489"
  license "Apache-2.0"
  head "https://github.com/chainguard-dev/apko.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "000e90490851458379918dfafc7d7ec3d990870634b7d00110b6e3d6fc070147"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a205e41c1edcb5da502e23a2fda6e3d5308f7db61a3197c3c586769c6264c15f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b1f7b6475421c41defd78614bced06fb6538912cd9c3194b987f635521078fca"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8b70e416201c80cbd548d8b54b6e6b7041856a2078543cdb69f23aa573d88696"
    sha256 cellar: :any,                 x86_64_linux:      "11bb057992dc8c42ee55799b33d2d31d54409882a4bfd38b1b3f4a68cbbf4ede"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -X sigs.k8s.io/release-utils/version.gitVersion=#{version}
      -X sigs.k8s.io/release-utils/version.gitCommit=#{tap.user}
      -X sigs.k8s.io/release-utils/version.gitTreeState=clean
      -X sigs.k8s.io/release-utils/version.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"apko", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"test.yml").write <<~YAML
      contents:
        repositories:
          - https://dl-cdn.alpinelinux.org/alpine/edge/main
        packages:
          - apk-tools

      entrypoint:
        command: /bin/sh -l

      # optional environment configuration
      environment:
        PATH: /usr/sbin:/sbin:/usr/bin:/bin

      # only key found for arch riscv64 [edge],
      archs:
        - riscv64
    YAML
    system bin/"apko", "build", testpath/"test.yml", "apko-alpine:test", "apko-alpine.tar"
    assert_path_exists testpath/"apko-alpine.tar"

    assert_match version.to_s, shell_output("#{bin}/apko version")
  end
end
