class Edgevpn < Formula
  desc "Immutable, decentralized, statically built p2p VPN"
  homepage "https://mudler.github.io/edgevpn"
  url "https://github.com/mudler/edgevpn/archive/refs/tags/v0.37.2.tar.gz"
  sha256 "b7bab4833cd651973aa54241d6516f6d91efe97b67f98704634e479e13e7d30c"
  license "Apache-2.0"
  head "https://github.com/mudler/edgevpn.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "e29f70163a82ae625664f88cdea9a3a0544eb38d2b9df4226a74a8ae7e87fad9"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  deny_network_access!

  def fetch
    cd "api/react-ui" do
      system "npm", "ci"
    end
    system "go", "mod", "download"
  end

  def install
    cd "api/react-ui" do
      system "npm", "run", "build"
    end

    ldflags = %W[-X github.com/mudler/edgevpn/internal.Version=#{version}]

    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    generate_token_output = pipe_output("#{bin}/edgevpn -g")
    assert_match "otp:", generate_token_output
    assert_match "max_message_size: 20971520", generate_token_output
  end
end
