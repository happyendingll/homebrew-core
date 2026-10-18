class Juju < Formula
  desc "DevOps management tool"
  homepage "https://canonical.com/juju"
  url "https://github.com/juju/juju/archive/refs/tags/v4.0.16.tar.gz"
  sha256 "d01fdd2778628b99d6c920d523efdfb6271a98e9ff32311fd953bcd59b901691"
  license "AGPL-3.0-only"
  version_scheme 1
  head "https://github.com/juju/juju.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "10f6fa4772d13d1a50d60be390af63d0a1f2ee7c3eb621a01f22b395885be218"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/juju"
    system "go", "build", *std_go_args(output: bin/"juju-metadata"), "./cmd/plugins/juju-metadata"
    bash_completion.install "etc/bash_completion.d/juju"
  end

  test do
    system bin/"juju", "version"
    assert_match "No controllers registered", shell_output("#{bin}/juju list-users 2>&1", 1)
    assert_match "No controllers registered", shell_output("#{bin}/juju-metadata list-images 2>&1", 2)
  end
end
