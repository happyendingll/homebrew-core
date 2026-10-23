class Doggo < Formula
  desc "Command-line DNS Client for Humans"
  homepage "https://doggo.mrkaran.dev/"
  url "https://github.com/mr-karan/doggo/archive/refs/tags/v1.4.2.tar.gz"
  sha256 "9c5d1d0d800f72e80d35f6731fa3a80435f5a1af08af900a6b77142600e19395"
  license "GPL-3.0-or-later"
  head "https://github.com/mr-karan/doggo.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8f2871f1f4de3931e58fd53cfefe13b8ed329b833115e27a73478d4912652447"
  end

  depends_on "go" => :build

  # `test do` block performs DNS lookups
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.buildVersion=#{version} -X main.buildDate=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/doggo"

    generate_completions_from_executable(bin/"doggo", "completions")
  end

  test do
    answer = shell_output("#{bin}/doggo --short example.com NS @1.1.1.1")
    assert_equal "hera.ns.cloudflare.com.\nelliott.ns.cloudflare.com.\n", answer

    assert_match version.to_s, shell_output("#{bin}/doggo --version")
  end
end
