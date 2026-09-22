class Asdf < Formula
  desc "Extendable version manager with support for Ruby, Node.js, Erlang & more"
  homepage "https://asdf-vm.com/"
  url "https://github.com/asdf-vm/asdf/archive/refs/tags/v0.20.1.tar.gz"
  sha256 "070281c31d7576b5089a39374bc5674649b439adae5ddaeb69c697a756a28a4f"
  license "MIT"
  head "https://github.com/asdf-vm/asdf.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1c9de3f0417bea2e23f31aebeb02ac15aee25acce9f75b5c575cfb0c16d1b920"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1c9de3f0417bea2e23f31aebeb02ac15aee25acce9f75b5c575cfb0c16d1b920"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1c9de3f0417bea2e23f31aebeb02ac15aee25acce9f75b5c575cfb0c16d1b920"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "752821bbd8e7c78b577cddf0a0bdc39147cb450ce8df7056290235425d80e259"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "bafbfb021fe3fed1e7f26eb7c1f370fc09a280f556ecbe2072164494d8118418"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # fix https://github.com/asdf-vm/asdf/issues/1992
    # relates to https://github.com/Homebrew/homebrew-core/issues/163826
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/asdf"
    generate_completions_from_executable(bin/"asdf", "completion")
    libexec.install Dir["asdf.*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asdf version")
    assert_match "No plugins installed", shell_output("#{bin}/asdf plugin list 2>&1")
  end
end
