class Portop < Formula
  desc "Terminal UI showing which processes are using TCP and UDP ports"
  homepage "https://github.com/padovanl/portop"
  url "https://github.com/padovanl/portop/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "4fb55f6146fd85fe1a05af00b1281f123025e29e1b9ba3f165d2413ce0a02343"
  license "MIT"
  head "https://github.com/padovanl/portop.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ec0541e583019a2ecf8a98abd5526c7267bcd7035e53bf19fbc84f94052cb231"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/padovanl/portop/internal/cli.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/portop"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/portop --version")
    assert_kind_of Array, JSON.parse(shell_output("#{bin}/portop --json"))
  end
end
