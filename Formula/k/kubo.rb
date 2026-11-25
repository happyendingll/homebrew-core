class Kubo < Formula
  desc "Peer-to-peer hypermedia protocol"
  homepage "https://docs.ipfs.tech/how-to/command-line-quick-start/"
  url "https://github.com/ipfs/kubo/releases/download/v0.43.2/kubo-source.tar.gz"
  sha256 "ac09ffea8d5e38903f8e96b3b8de63b6dd915c982718084f0079ae7a45785acc"
  license all_of: [
    "MIT",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/ipfs/kubo.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "d763d94e065cc03849a5479ef87042286810d2690c2c89b0a506bc6afa6b890f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/ipfs/kubo.CurrentCommit=#{tap.user}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"ipfs"), "./cmd/ipfs"

    generate_completions_from_executable(bin/"ipfs", "commands", "completion")
  end

  service do
    run [opt_bin/"ipfs", "daemon"]
  end

  test do
    assert_match "initializing IPFS node", shell_output("#{bin}/ipfs init")
  end
end
