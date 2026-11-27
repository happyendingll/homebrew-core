class Goat < Formula
  desc "General purpose AT Protocol CLI in Go"
  homepage "https://github.com/bluesky-social/goat"
  url "https://github.com/bluesky-social/goat/archive/refs/tags/v0.2.10.tar.gz"
  sha256 "259ade7fab8301c65a88d3a4add23b1a286bc3ff0b7bc233c5e45cb03679c498"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "4d5424c13f58a9e2dc66aaccefa9277fec3239b832b07d7cd8fe8832bb4ecd59"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goat --version")

    output = shell_output("#{bin}/goat get at://atproto.com/app.bsky.actor.profile/self")
    assert_match "\"$type\": \"app.bsky.actor.profile\"", output
    assert_match "\"displayName\": \"AT Protocol Developers\"", output
  end
end
