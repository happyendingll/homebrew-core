class Goat < Formula
  desc "General purpose AT Protocol CLI in Go"
  homepage "https://github.com/bluesky-social/goat"
  url "https://github.com/bluesky-social/goat.git",
      tag:      "v0.2.5",
      revision: "53ba4f937b70be32a89e8cf1b2bd998c8590ceaa"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "519ce2cb29154be5f8705b3eb9921f1495d2e3be02ade7caa15699fc4009bf2b"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goat --version")

    output = shell_output("#{bin}/goat get at://atproto.com/app.bsky.actor.profile/self")
    assert_match "Social networking technology created by Bluesky.", output
    assert_match "\"displayName\": \"AT Protocol Developers\"", output
  end
end
