class Asc < Formula
  desc "Fast, lightweight CLI for App Store Connect"
  homepage "https://asccli.sh"
  url "https://github.com/rorkai/App-Store-Connect-CLI/archive/refs/tags/5.3.3.tar.gz"
  sha256 "c9518bfa076cbc13c385653c76ad5ed0bfa081fb14e99290f2ee685634a45720"
  license "MIT"
  head "https://github.com/rorkai/App-Store-Connect-CLI.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ba12a885a28fc45699c07851eb6f3511532913f8e070437450396c878b91180a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "262f81a0a42f3b8c12d2e72448a6a5adb21ff41c5f343f35970ae35400e28815"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "eb3166aee9d4c54d0ac63dc66cea126eaacee8e72dd99e27cfac1a9366c1b95d"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d545fda6cb7d76660a95a3a905c60fbac31bbbec960786fe3f933cdcade841c8"
    sha256 cellar: :any,                 x86_64_linux:      "9f51f12e3531bc850a40d8b4b87a38200d61564b89a9259fe3aa320d6a7d3563"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"asc", "completion", "--shell")
  end

  test do
    system bin/"asc", "init", "--path", testpath/"ASC.md", "--link=false"
    assert_path_exists testpath/"ASC.md"
    assert_match "asc cli reference", (testpath/"ASC.md").read
    assert_match version.to_s, shell_output("#{bin}/asc version")
  end
end
