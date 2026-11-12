class Fetch < Formula
  desc "Download assets from a commit, branch, or tag of GitHub repositories"
  homepage "https://www.gruntwork.io/"
  url "https://github.com/gruntwork-io/fetch/archive/refs/tags/v0.4.9.tar.gz"
  sha256 "4d0a62de2afe4519324815570fbf0eea75edb7b29734844f403d91f13b32e034"
  license "MIT"
  head "https://github.com/gruntwork-io/fetch.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7926f5065a4a9623ef0eeb3c304f2b1fb4973a3b0b120bb26ed0544d2249e474"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.VERSION=v#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fetch --version")

    repo_url = "https://github.com/gruntwork-io/fetch"

    assert_match "Downloading asset SHA256SUMS to SHA256SUMS",
      shell_output("#{bin}/fetch --repo=\"#{repo_url}\" --tag=\"v0.4.6\" --release-asset=\"SHA256SUMS\" . 2>&1")
  end
end
