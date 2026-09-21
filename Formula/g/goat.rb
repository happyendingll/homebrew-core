class Goat < Formula
  desc "General purpose AT Protocol CLI in Go"
  homepage "https://github.com/bluesky-social/goat"
  url "https://github.com/bluesky-social/goat.git",
      tag:      "v0.2.4",
      revision: "f80010584f9bedd7d0e0a0100814e28e887f1cbc"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "6014cddfc7c8d236b624a5171fcf1be31864f895ba3492498bbbf8a1d91d160c"
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
