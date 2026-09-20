class Charm < Formula
  desc "Tool for managing Juju Charms"
  homepage "https://github.com/juju/charmstore-client"
  url "https://github.com/juju/charmstore-client/archive/refs/tags/v2.5.2.tar.gz"
  sha256 "3dd52c9a463bc09bedb3a07eb0977711aec77611b9c0d7f40cd366a66aa2ca03"
  license "GPL-3.0-only"
  head "https://github.com/juju/charmstore-client.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "1a4820e3cef4da34fdb1b38e186a6ef0cf910f05e86fb2d722866878aa2d56f8"
  end

  depends_on "breezy" => :build
  # Go 1.27 dropped bzr support: https://github.com/golang/go/issues/78090
  depends_on "go@1.26" => :build

  deny_network_access!

  def fetch
    # Charm requires bzr (bazaar vcs) for fetching launchpad.net/lpad Go module.
    ENV["GOVCS"] = "launchpad.net:bzr"
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/charm"
  end

  test do
    assert_match "show-plan           - show plan details", shell_output("#{bin}/charm 2>&1")

    assert_match "ERROR missing plan url", shell_output("#{bin}/charm show-plan 2>&1", 2)
  end
end
