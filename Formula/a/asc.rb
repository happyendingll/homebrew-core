class Asc < Formula
  desc "Fast, lightweight CLI for App Store Connect"
  homepage "https://asccli.sh"
  url "https://github.com/rorkai/App-Store-Connect-CLI/archive/refs/tags/5.14.2.tar.gz"
  sha256 "5211cc975b606e4f26f469891cfd1cb0ab7c161c40fae6145cc6ce8ac234a995"
  license "MIT"
  head "https://github.com/rorkai/App-Store-Connect-CLI.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4373663d45e613666f29a43eaa4a9ba8a59371b3cb6424ccd530b84ac8a7736c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8652b6a0bbaeaa4178d6cd405f12905dca7b52aa4b97cd2b91b48fb20e24e63f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "54ceba2a4c20a952afae97223b853c9e3c9119214dc26cc6640c173d8c235568"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "13b217effaac8fb6707d240a7ef6416479888adffe3ab474428cbba8c9167f36"
    sha256 cellar: :any,                 x86_64_linux:      "0cfd9c49bcadb63d95115953058d6f5193fbde52b7daf75e055856a5826c77e3"
  end

  depends_on "go" => :build

  conflicts_with "asccli", because: "both install `asc` binaries"

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
