class Tanka < Formula
  desc "Flexible, reusable and concise configuration for Kubernetes using Jsonnet"
  homepage "https://tanka.dev"
  url "https://github.com/grafana/tanka/archive/refs/tags/v0.39.5.tar.gz"
  sha256 "3f08730f6e55f17992314c3edbdb3e6e69b665dd05d641b87b3c81d2de2d1725"
  license "Apache-2.0"
  head "https://github.com/grafana/tanka.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2936c51139f9bf6f1e76e8ec6ce6ce6417a8668834f66cee50fac5598f8792d2"
  end

  depends_on "go" => :build
  depends_on "kubernetes-cli"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[-X github.com/grafana/tanka/pkg/tanka.CurrentVersion=#{version}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"tk"), "./cmd/tk"
  end

  test do
    system "git", "clone", "https://github.com/sh0rez/grafana.libsonnet"
    system bin/"tk", "show", "--dangerous-allow-redirect", "grafana.libsonnet/environments/default"
  end
end
