class Regclient < Formula
  desc "Docker and OCI Registry Client in Go and tooling using those libraries"
  homepage "https://regclient.org/"
  url "https://github.com/regclient/regclient/archive/refs/tags/v0.11.7.tar.gz"
  sha256 "a648fcf3b5b81c55773f47f6d7401d1904675c32520a76159d960a9e8798badd"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/regclient/regclient.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2ee94e2e300d3f8c18ba4b89b638a6131c375a01536e461234a9ec151ee3bffa"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/regclient/regclient/internal/version.vcsTag=#{version}"
    ["regbot", "regctl", "regsync"].each do |f|
      system "go", "build", *std_go_args(ldflags:, output: bin/f), "./cmd/#{f}"

      generate_completions_from_executable(bin/f, shell_parameter_format: :cobra)
    end
  end

  test do
    output = shell_output("#{bin}/regctl image manifest docker.io/library/alpine:latest")
    assert_match "docker.io/library/alpine:latest", output

    assert_match version.to_s, shell_output("#{bin}/regbot version")
    assert_match version.to_s, shell_output("#{bin}/regctl version")
    assert_match version.to_s, shell_output("#{bin}/regsync version")
  end
end
